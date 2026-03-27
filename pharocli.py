#!/usr/bin/env python3

import argparse
import socket
import subprocess
import sys
import re


class PharoCLI:
    def __init__(self, port=4044):
        self.port = port
    
    def execute(self, smalltalk_code):
        """Execute Smalltalk code on the Pharo image and return result."""
        try:
            result = subprocess.run(
                ["nc", "localhost", str(self.port)],
                input=smalltalk_code,
                capture_output=True,
                text=True,
                timeout=5
            )
            # Remove surrounding quotes and normalize line endings
            output = result.stdout.strip()
            if output.startswith("'") and output.endswith("'"):
                output = output[1:-1]
            # Normalize CR/CRLF to newlines
            output = output.replace('\r\r', '\n\n').replace('\r', '\n')
            return output
        except Exception as e:
            print(f"Error executing Smalltalk: {e}", file=sys.stderr)
            return None
    
    def _build_set(self, elements):
        """Build Smalltalk set/array syntax from list of elements."""
        if not elements:
            return "#()"
        return "{" + ". ".join(elements) + "}"
    
    def build_array(self, items, as_symbols=True):
        """Build a Smalltalk array from a list of items."""
        if not items:
            return "#()"
        elements = []
        for item in items:
            if ">>" in item:
                # Method reference, don't convert
                elements.append(item)
            elif as_symbols:
                elements.append(f"#{item}")
            else:
                elements.append(f"'{item}'")
        return self._build_set(elements)
    
    def build_class_array(self, class_names):
        """Build Smalltalk array of class objects from class names."""
        classes = [f"(PharoCLI classFromName: '{c}')" for c in class_names]
        return self._build_set(classes)
    
    def parse_method_ref(self, ref):
        """Parse a method reference like 'Object>> yourself' into (class, method)."""
        match = re.match(r'(\w+)\s*>>\s*(.+)', ref)
        if not match:
            raise ValueError(f"Invalid method reference: {ref}")
        return match.group(1), match.group(2).strip()


def main():
    cli = PharoCLI()
    
    parser = argparse.ArgumentParser(
        description='PharoCLI - Command-line interface to Pharo image inspection',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  pharocli packages
  pharocli packages classes Kernel Collections
  pharocli protocols Object String
  pharocli methods Object --protocols accessing
  pharocli implementors yourself
  pharocli source "Object>> yourself"
  pharocli search cache --in-packages Kernel
        """
    )
    
    parser.add_argument('-p', '--port', type=int, default=4044,
                        help='Port number for Pharo image (default: 4044)')
    
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # ===== packages command =====
    pkg_parser = subparsers.add_parser('packages', help='Package management')
    pkg_subs = pkg_parser.add_subparsers(dest='subcommand')
    
    pkg_subs.add_parser('list', help='List all top-level packages')
    
    pkg_classes = pkg_subs.add_parser('classes', help='List classes in packages')
    pkg_classes.add_argument('packages', nargs='+')
    
    pkg_sub = pkg_subs.add_parser('sub', help='List sub-packages')
    pkg_sub.add_argument('packages', nargs='+')
    
    pkg_ext = pkg_subs.add_parser('extended', help='Get classes extended by package')
    pkg_ext.add_argument('package')
    
    pkg_methods = pkg_subs.add_parser('extensions', help='Get extension methods in package')
    pkg_methods.add_argument('package')
    
    # ===== protocols command =====
    proto_parser = subparsers.add_parser('protocols', help='Get class protocols')
    proto_parser.add_argument('classes', nargs='+')
    proto_parser.add_argument('--extensions-only', action='store_true')
    proto_parser.add_argument('--without-extensions', action='store_true')
    
    # ===== methods command =====
    methods_parser = subparsers.add_parser('methods', help='Get class methods')
    methods_parser.add_argument('classes', nargs='+')
    methods_parser.add_argument('--protocols', nargs='+')
    
    # ===== implementors command =====
    impl_parser = subparsers.add_parser('implementors', help='Find implementors of selector')
    impl_parser.add_argument('selector')
    impl_parser.add_argument('--in-package', dest='in_package')
    impl_parser.add_argument('--in-packages', nargs='+')
    
    # ===== senders command =====
    senders_parser = subparsers.add_parser('senders', help='Find senders of selector')
    senders_parser.add_argument('selector')
    senders_parser.add_argument('--in-package', dest='in_package')
    senders_parser.add_argument('--in-packages', nargs='+')
    
    # ===== source command =====
    source_parser = subparsers.add_parser('source', help='Get method source code')
    source_parser.add_argument('method_ref', help='Method reference (Class>> method)')
    
    # ===== sources command =====
    sources_parser = subparsers.add_parser('sources', help='Get multiple method sources')
    sources_parser.add_argument('method_refs', nargs='+', help='Method references (Class>> method)')
    
    # ===== info command =====
    info_parser = subparsers.add_parser('info', help='Get method information')
    info_parser.add_argument('method_ref', help='Method reference (Class>> method)')
    
    # ===== hierarchy command =====
    hier_parser = subparsers.add_parser('hierarchy', help='Show class hierarchy')
    hier_parser.add_argument('class_name')
    
    # ===== comment command =====
    comment_parser = subparsers.add_parser('comment', help='Get class comment')
    comment_parser.add_argument('class_name')
    
    # ===== variables command =====
    vars_parser = subparsers.add_parser('variables', help='List class variables')
    vars_parser.add_argument('class_name')
    
    # ===== instvar command =====
    instvar_parser = subparsers.add_parser('instvar', help='Find methods accessing variable')
    instvar_parser.add_argument('class_name')
    instvar_parser.add_argument('variable')
    
    # ===== references command =====
    refs_parser = subparsers.add_parser('references', help='Find class references')
    refs_parser.add_argument('class_name')
    refs_parser.add_argument('--in-package', dest='in_package')
    refs_parser.add_argument('--in-packages', nargs='+')
    
    # ===== search command =====
    search_parser = subparsers.add_parser('search', help='Search for methods')
    search_parser.add_argument('keyword')
    search_parser.add_argument('--in-packages', nargs='+')
    search_parser.add_argument('--in-classes', nargs='+')
    search_parser.add_argument('--fields', nargs='+')
    search_parser.add_argument('--case-sensitive', action='store_true')
    
    # ===== debugger command =====
    dbg_parser = subparsers.add_parser('debugger', help='Debugger commands')
    dbg_subs = dbg_parser.add_subparsers(dest='subcommand')
    
    dbg_stack = dbg_subs.add_parser('stack', help='Show debugger stack')
    dbg_stack.add_argument('indices', nargs='*', type=int, help='Optional frame indices')
    
    dbg_vars = dbg_subs.add_parser('vars', help='Show debugger variables')
    dbg_vars.add_argument('indices', nargs='*', type=int, help='Optional frame indices')
    
    # ===== inspect command =====
    insp_parser = subparsers.add_parser('inspect', help='Inspect objects')
    insp_subs = insp_parser.add_subparsers(dest='subcommand')
    
    insp_tree = insp_subs.add_parser('tree', help='Inspect as tree')
    insp_tree.add_argument('expression', help='Smalltalk expression')
    insp_tree.add_argument('depth', nargs='?', type=int, default=3, help='Tree depth (1-5)')
    
    # ===== compile command =====
    compile_parser = subparsers.add_parser('compile', help='Compile a method')
    compile_parser.add_argument('class_name')
    compile_parser.add_argument('--source', required=True, help='Method source code')
    compile_parser.add_argument('--protocol', default='unclassified')
    compile_parser.add_argument('--class-method', action='store_true', help='Compile as class method')
    
    # ===== packageinfo command =====
    pkginfo_parser = subparsers.add_parser('packageinfo', help='Get detailed package information as JSON')
    pkginfo_parser.add_argument('packages', nargs='+', help='Package names')
    
    args = parser.parse_args()
    cli.port = args.port
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    # Dispatch to handler using dictionary lookup
    handlers = {
        'packages': handle_packages,
        'protocols': handle_protocols,
        'methods': handle_methods,
        'implementors': handle_implementors,
        'senders': handle_senders,
        'source': handle_source,
        'sources': handle_sources,
        'info': handle_info,
        'hierarchy': handle_hierarchy,
        'comment': handle_comment,
        'variables': handle_variables,
        'instvar': handle_instvar,
        'references': handle_references,
        'search': handle_search,
        'debugger': handle_debugger,
        'inspect': handle_inspect,
        'compile': handle_compile,
        'packageinfo': handle_packageinfo,
    }
    handler = handlers.get(args.command)
    if handler:
        handler(cli, args)


def handle_packages(cli, args):
    if not args.subcommand or args.subcommand == 'list':
        print(cli.execute("PharoCLI topLevelPackagesString"))
    elif args.subcommand == 'classes':
        packages = cli.build_array(args.packages)
        print(cli.execute(f"PharoCLI classesInPackagesString: {packages}"))
    elif args.subcommand == 'sub':
        packages = cli.build_array(args.packages)
        print(cli.execute(f"PharoCLI subPackagesOfString: {packages}"))
    elif args.subcommand == 'extended':
        print(cli.execute(f"PharoCLI extendedClassesInPackageString: '{args.package}'"))
    elif args.subcommand == 'extensions':
        print(cli.execute(f"PharoCLI extensionMethodsInPackageString: '{args.package}'"))


def handle_protocols(cli, args):
    classes_code = cli.build_class_array(args.classes)
    suffix = ""
    if args.extensions_only:
        suffix = " extensionsOnly: true"
    elif args.without_extensions:
        suffix = " withoutExtensions: true"
    print(cli.execute(f"PharoCLI protocolsInClassesString: {classes_code}{suffix}"))


def handle_methods(cli, args):
    classes_code = cli.build_class_array(args.classes)
    protocols = cli.build_array(args.protocols) if args.protocols else "#()"
    print(cli.execute(f"PharoCLI methodsInClassesString: {classes_code} protocols: {protocols}"))


def _handle_with_optional_package_filter(cli, method_name, target, in_package, in_packages):
    """Generic handler for queries with optional --in-package / --in-packages filters.
    
    Note: String variants only exist without filters. When filtering, use non-String variants.
    """
    if in_package:
        # Use non-String variant for package filtering
        print(cli.execute(f"PharoCLI {method_name}: {target} inPackage: '{in_package}'"))
    elif in_packages:
        # Use non-String variant for package filtering
        packages = cli.build_array(in_packages)
        print(cli.execute(f"PharoCLI {method_name}: {target} inPackages: {packages}"))
    else:
        # Use String variant when no filtering
        print(cli.execute(f"PharoCLI {method_name}String: {target}"))

def handle_implementors(cli, args):
    _handle_with_optional_package_filter(cli, 'implementorsOf', f"#{args.selector}", args.in_package, args.in_packages)

def handle_senders(cli, args):
    _handle_with_optional_package_filter(cli, 'sendersOf', f"#{args.selector}", args.in_package, args.in_packages)


def _method_to_smalltalk(cli, ref):
    """Convert method reference to Smalltalk code."""
    class_name, method = cli.parse_method_ref(ref)
    return f"((PharoCLI classFromName: '{class_name}') >> #{method})"

def handle_source(cli, args):
    method_code = _method_to_smalltalk(cli, args.method_ref)
    print(cli.execute(f"PharoCLI sourceOfMethodFormatted: {method_code}"))

def handle_sources(cli, args):
    methods = [_method_to_smalltalk(cli, ref) for ref in args.method_refs]
    methods_code = cli._build_set(methods)
    print(cli.execute(f"PharoCLI sourceOfMethodsFormatted: {methods_code}"))

def handle_info(cli, args):
    method_code = _method_to_smalltalk(cli, args.method_ref)
    print(cli.execute(f"PharoCLI methodInfoString: {method_code}"))

def _handle_class_query(cli, class_name, method_name):
    """Generic handler for class-based queries."""
    print(cli.execute(f"PharoCLI {method_name}String: (PharoCLI classFromName: '{class_name}')"))

def handle_hierarchy(cli, args):
    _handle_class_query(cli, args.class_name, 'hierarchyOf')

def handle_comment(cli, args):
    _handle_class_query(cli, args.class_name, 'commentOf')

def handle_variables(cli, args):
    _handle_class_query(cli, args.class_name, 'variablesOf')

def handle_instvar(cli, args):
    print(cli.execute(f"PharoCLI referencesToInstanceVariableString: #{args.variable} inClass: #{args.class_name}"))


def handle_references(cli, args):
    """Find class references with optional package filter."""
    _handle_with_optional_package_filter(cli, 'referencesOf', f"#{args.class_name}", args.in_package, args.in_packages)


def handle_search(cli, args):
    packages_code = "nil" if not args.in_packages else cli.build_array(args.in_packages)
    classes_code = "nil" if not args.in_classes else cli.build_array(args.in_classes)
    fields_code = "#(names source comment)" if not args.fields else cli.build_array(args.fields)
    case_sensitive = "true" if args.case_sensitive else "false"
    
    print(cli.execute(
        f"PharoCLI searchForString: '{args.keyword}' inPackages: {packages_code} "
        f"inClasses: {classes_code} searchFields: {fields_code} caseSensitive: {case_sensitive}"
    ))


def handle_debugger(cli, args):
    """Handle debugger stack/vars with optional frame indices."""
    method_map = {'stack': 'debuggerStackSourceString', 'vars': 'debuggerStackVariablesString'}
    method_name = method_map.get(args.subcommand)
    
    if args.indices:
        indices = cli._build_set([str(i) for i in args.indices])
        print(cli.execute(f"PharoCLI {method_name}: {indices}"))
    else:
        print(cli.execute(f"PharoCLI {method_name}"))


def handle_inspect(cli, args):
    if args.subcommand == 'tree':
        if args.depth < 1 or args.depth > 5:
            print("Error: depth must be between 1 and 5", file=sys.stderr)
            sys.exit(1)
        print(cli.execute(f"PharoCLI objectTreeString: ({args.expression}) depth: {args.depth}"))


def handle_compile(cli, args):
    # Use our new compile method with protocol support
    source = args.source.replace('\n', '\r').replace("'", "''")
    if args.class_method:
        print(cli.execute(
            f"PharoCLI compileClassMethodInClass: '{args.class_name}' "
            f"source: '{source}' protocol: '{args.protocol}'"
        ))
    else:
        print(cli.execute(
            f"PharoCLI compileMethodInClass: '{args.class_name}' "
            f"source: '{source}' protocol: '{args.protocol}'"
        ))


def handle_packageinfo(cli, args):
    """Get detailed package information as JSON."""
    packages_array = cli._build_set([f"'{p}'" for p in args.packages])
    result = cli.execute(f"PharoCLI new packageInfoJSON: {packages_array}")
    print(result)


if __name__ == '__main__':
    main()
