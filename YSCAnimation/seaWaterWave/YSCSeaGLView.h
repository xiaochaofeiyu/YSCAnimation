//
//  YSCSeaGLView.h
//
//
//  Created by yushichao on 16/3/18.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface YSCSeaGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    float _currentRotation;
    GLuint _depthRenderBuffer;
    
    GLuint _floorTexture;
    GLuint _fishTexture;
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    GLuint _textureUniform2;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    GLuint _iResolutionUniform;
    GLuint _iGlobalTimeUniform;
}

- (void)removeFromParent;

@end
