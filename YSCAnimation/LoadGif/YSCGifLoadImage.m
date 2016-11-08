//
//  YSCGifLoadImage.m
//  MISVoiceSearchLib
//
//  Created by yushichao on 16/10/18.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCGifLoadImage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

//获取当前ref的时间
inline static NSTimeInterval CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource, NSUInteger index)
{
    NSTimeInterval frameDuration = 0;
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
        CFDictionaryRef gifProperties;
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties)) {
            const void *frameDurationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
                frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                if (frameDuration <= 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
                        frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }
    
#ifndef OLExactGIFRepresentation
    //Implement as Browsers do.
    //See:  http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
    //Also: http://blogs.msdn.com/b/ieinternals/archive/2010/06/08/animated-gifs-slow-down-to-under-20-frames-per-second.aspx
    
    if (frameDuration < 0.02 - FLT_EPSILON) {
        frameDuration = 0.1;
    }
#endif
    return frameDuration;
}

//判断是否是gif
inline static BOOL CGImageSourceContainsAnimatedGif(CGImageSourceRef imageSource)
{
    return imageSource && UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1;
}

//判断是否是双倍图
inline static BOOL isRetinaFilePath(NSString *path)
{
    NSRange retinaSuffixRange = [[path lastPathComponent] rangeOfString:@"@2x" options:NSCaseInsensitiveSearch];
    return retinaSuffixRange.length && retinaSuffixRange.location != NSNotFound;
}

@interface YSCGifLoadImage ()
{
    CGImageSourceRef _imageSourceRef;
    CGFloat _scale;
    dispatch_queue_t readFrameQueue;
}
@property (nonatomic,readwrite) NSTimeInterval   *frameDurations;
@property (nonatomic,readwrite) NSUInteger       loopCount;
@property (nonatomic,readwrite) NSMutableArray   *images;
@property (nonatomic,readwrite) NSTimeInterval   totalDuratoin;
@property (nonatomic,readwrite) CGImageSourceRef incrementalSource;
@end

static int _prefetchedNum = 10;

@implementation YSCGifLoadImage
@synthesize images;

#pragma mark 重写UIImage的创建方法
- (id)initWithContentsOfFile:(NSString *)path
{
    return [self initWithData:[NSData dataWithContentsOfFile:path]
                        scale:isRetinaFilePath(path) ? 2.0f : 1.0f];
}

- (id)initWithData:(NSData *)data
{
    return [self initWithData:data scale:1.0f];
}

- (id)initWithData:(NSData *)data scale:(CGFloat)scale
{
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    //如果是gif图，就用这种方式创建
    if (CGImageSourceContainsAnimatedGif(imageSource)) {
        self = [self initWithCGImageSource:imageSource scale:scale];
    } else {
        if (scale == 1.0f) {
            self = [super initWithData:data];
        } else {
            self = [super initWithData:data scale:scale];
        }
    }
    
    if (imageSource) {
        CFRelease(imageSource);
    }
    
    return self;
}

//创建gif图片
-(instancetype)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale
{
    self = [super init];
    if (!imageSource || !self) {
        return nil;
    }
    CFRetain(imageSource);
    
    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
    
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(imageSource, NULL));
    NSDictionary *gifProperties = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    //开辟空间
    self.frameDurations = (NSTimeInterval *)malloc(numberOfFrames  * sizeof(NSTimeInterval));
    //读取循环次数
    self.loopCount = [gifProperties[(NSString *)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
    //创建所有图片的数值
    self.images = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    NSNull *aNull = [NSNull null];
    for (NSUInteger i = 0; i < numberOfFrames; ++i) {
        //读取每张土拍的显示时间,添加到数组中,并计算总时间
        [self.images addObject:aNull];
        NSTimeInterval frameDuration = CGImageSourceGetGifFrameDelay(imageSource, i);
        self.frameDurations[i] = frameDuration;
        self.totalDuratoin += frameDuration;
    }
    //CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    // Load first frame
    NSUInteger num = MIN(_prefetchedNum, numberOfFrames);
    for (int i=0; i<num; i++) {
        //替换读取到的每一张图片
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        [self.images replaceObjectAtIndex:i withObject:[UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp]];
        CFRelease(image);
    }
    //释放资源,创建子队列
    _imageSourceRef = imageSource;
    CFRetain(_imageSourceRef);
    CFRelease(imageSource);
    //});
    
    _scale = scale;
    readFrameQueue = dispatch_queue_create("com.baidu.readGif", DISPATCH_QUEUE_SERIAL);
    
    return self;
}

#pragma mark -Class Methods

+(UIImage *)imageNamed:(NSString *)name
{
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:name];
    return ([[NSFileManager defaultManager] fileExistsAtPath:path] ? [self imageWithContentsOfFile:path] :nil);
}

+(UIImage *)imageWithContentsOfFile:(NSString *)path
{
    return [self imageWithData:[NSData dataWithContentsOfFile:path] scale:isRetinaFilePath(path) ? 2.0 : 1.0];
}

+(UIImage *)imageWithData:(NSData *)data
{
    return [self imageWithData:data scale:1.0f];
}

+(UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale
{
    if (!data) {
        return nil;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    UIImage *image;
    if (CGImageSourceContainsAnimatedGif(imageSource)) {
        image = [[self alloc] initWithCGImageSource:imageSource scale:scale];
    }else{
        image = [super imageWithData:data scale:scale];
    }
    if (imageSource) {
        CFRelease(imageSource);
    }
    return image;
}

#pragma mark custom method

-(UIImage *)getFrameWithIndex:(NSUInteger)idx
{
    if (idx >= self.images.count) {
        return self.images[0];
    }
    //根据当前index 来获取gif图片的第几个图片
    UIImage *frame = nil;
    @synchronized (self.images) {
        frame = self.images[idx];
    }
    //放回对应index的图片
    if (!frame) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSourceRef, idx, NULL);
        frame = [UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp];
        CFRelease(image);
    }
    /**
     *  如果图片张数大于10，进行如下操作的目的是
     由于该方法会频繁调用，为加快速度和节省内存，对取值所在的数组进行了替换，只保留10个内容
     并随着的不断增大，对原来被替换的内容进行还原，但是被还原的个数和保留的个数总共为10个，这个是最开始进行的设置的大小
     */
    if (self.images.count > _prefetchedNum) {
        if (idx != 0) {
            [self.images replaceObjectAtIndex:idx withObject:[NSNull null]];
        }
        NSUInteger nextReadIdx = idx + _prefetchedNum;
        //        for (NSUInteger i = idx + 1; i <= nextReadIdx; i++) {
        //保证每次的index都小于数组个数，从而使最大值的下一个是最小值
        NSUInteger _idx = nextReadIdx%self.images.count;
        if ([self.images[_idx] isKindOfClass:[NSNull class]]) {
            dispatch_async(readFrameQueue, ^{
                CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSourceRef, _idx, NULL);
                @synchronized (self.images) {
                    [self.images replaceObjectAtIndex:_idx withObject:[UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp]];
                }
                CFRelease(image);
            });
        }
        //        }
    }
    return frame;
}

-(CGSize)size
{
    if (self.images.count) {
        return [[self.images objectAtIndex:0] size];
    }
    return [super size];
}

-(CGImageRef)CGImage
{
    if (self.images.count) {
        return [[self.images objectAtIndex:0] CGImage];
    }
    return [super CGImage];
}

-(UIImageOrientation)imageOrientation
{
    if (self.images.count) {
        return [[self.images objectAtIndex:0] imageOrientation];
    }
    return [super imageOrientation];
}

-(CGFloat)scale
{
    if (self.images.count) {
        return [(UIImage *)[self.images objectAtIndex:0] scale];
    }
    return [super scale];
}

-(NSTimeInterval)duration
{
    return self.images ? self.totalDuratoin : [super duration];
}

-(void)dealloc
{
    if (_imageSourceRef) {
        CFRelease(_imageSourceRef);
    }
    free(_frameDurations);
    if (_incrementalSource) {
        CFRelease(_incrementalSource);
    }
}

@end
