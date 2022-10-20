// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -emit-module-path %t/NewModule.swiftmodule -module-name NewModule -enable-library-evolution %s -DNEW
// RUN: %target-swift-frontend -I %t %s -emit-ir -enable-library-evolution -whole-module-optimization -module-name OldModule | %FileCheck -check-prefix=SYMBOL %s


#if NEW

@available(macOS 10.15, iOS 13.0, macCatalyst 13.0, *)
@_originallyDefinedIn(module: "OldModule", macOS 12.0, iOS 15.0, macCatalyst 15.0)
open class Entity {
    public struct ComponentSet {
        public subscript<T>(_ componentType: T.Type) -> T? {
            get { fatalError() }
            set { fatalError() }
        }
    }

    public var components: ComponentSet {
        get { ComponentSet() }
        set { fatalError() }
    }
}

#else

import NewModule

@available(macOS 13.0, iOS 16.0, macCatalyst 16.0, *)
public class DerivedEntity: Entity {
    public var symbol: Int {
        get { components[Int.self]! }
        set { components[Int.self] = newValue }
    }
}


#endif

// SYMBOL: $s9OldModule6EntityC10componentsAC12ComponentSetVvM


// error: link command failed with exit code 1 (use -v to see invocation)
// Undefined symbols for architecture arm64:
//   "_$s9OldModule6EntityC10componentsAC12ComponentSetVvM", referenced from:
//       _$s9OldModule13DerivedEntityC6symbolSivs in OldModule-1.o
//   "_$s9OldModule6EntityC10componentsAC12ComponentSetVvg", referenced from:
//       _$s9OldModule13DerivedEntityC6symbolSivg in OldModule-1.o
// ld: symbol(s) not found for architecture arm64