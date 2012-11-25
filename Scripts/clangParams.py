import re

def parseClangCompileParams(args):
    className = ''
    objectCompilation = ''
    arch = ''
    isysroot = ''
    Lparams = []
    Fparams = []
    minOSParam=''
    idx = 0
    for arg in args:
    #    print('arg is %s' % arg)
        if (re.match('.*\w+\.mm?$', arg)):
            className = arg
            #        print('Found class name : ' + className)
        if (re.match('.*\w+\.o$', arg)):
            objectCompilation = arg
            #        print('Found object compilation name : ' + objectCompilation)
        if (re.match('^-L.*', arg)):
            Lparams = Lparams + [arg]
        if (re.match('^-F.*', arg)):
            Fparams = Fparams + [arg]
        if (arg == '-arch'):
            arch = args[idx+1]
        if (arg == '-isysroot'):
            isysroot = args[idx+1]
        if (re.match('^-mi.*-min=.*', arg)):
            minOSParam = arg

        idx += 1

    #print 'Class name : %s' % className
    #print 'Object name : %s ' % objectCompilation
    #print 'LParams %s' % Lparams
    #print 'FParams %s' % Fparams
    #print 'arch = %s ' % arch
    #print 'isysroot = %s ' % isysroot
    return {'class':className,
            'object':objectCompilation,
            'arch':arch,
            'isysroot':isysroot,
            'LParams':Lparams,
            'FParams':Fparams,
            'minOSParam':minOSParam
    }

