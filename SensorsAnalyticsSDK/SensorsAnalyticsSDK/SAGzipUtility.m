
/**
 @file SAGzipUtility.m
 @author Clint Harris (www.clintharris.net)
 
 Note: The code in this file has been commented so as to be compatible with
 Doxygen, a tool for automatically generating HTML-based documentation from
 source code. See http://www.doxygen.org for more info.
 */
#import "zlib.h"

#import "SAGzipUtility.h"


@implementation SAGzipUtility

/*******************************************************************************
 See header for documentation.
 */
+(NSData*) gzipData: (NSData*)pUncompressedData
{
    /*
     Special thanks to Robbie Hanson of Deusty Designs for sharing sample code
     showing how deflateInit2() can be used to make zlib generate a compressed
     file with gzip headers: