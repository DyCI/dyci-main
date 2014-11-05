//
// Created by Paul Taykalo on 11/5/14.
// Copyright (c) 2014 Stanfy. All rights reserved.
//
/**
* Force a category to be loaded when an app starts up.
*
* Add this macro before each category implementation, so we don't have to use
* -all_load or -force_load to load object files from static libraries that only contain
* categories and no classes.
* See http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html for more info.
*/
#define DYCI_FIX_CATEGORY_BUG(name) @interface DYCI_FIX_CATEGORY_BUG_##name : NSObject @end \
@implementation DYCI_FIX_CATEGORY_BUG_##name @end