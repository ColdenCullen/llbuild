module llbuild.plugin;
import llbuild.filefinders.filefinder;

import std.array: replace;

/**
 * Defines a static class for managing registered instances of a type.
 */
enum extendable( T ) = q{
    public static void register( $className inst )
    {
        // Register compiler if not already registered.
        if( !( typeid(inst) in instances ) )
            instances[typeid(inst)] = inst;
    }
    public static $className[] get$classNames() { return instances.values; }
    public static $className getByName( const string name )
    {
        import std.algorithm: filter;

        auto instWithName = instances.values.filter!( i => i.name == name );
        return instWithName.empty ? null : instWithName.front;
    }
    public static alias opIndex = getByName;
    private static $className[ClassInfo] instances;
}.replace( "$className", __traits(identifier, T) );

/**
 * Extend to automatically register this type with it's base.
 */
interface Extension( ThisClass, BaseClass )
{
    static this()
    {
        static assert( is(typeof(new ThisClass)), ThisClass.stringof ~ " must have a default constructor." );
        BaseClass.register( new ThisClass );
    }
}
