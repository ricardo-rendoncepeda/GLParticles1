//
//  ShaderProcessor.h
//  GLParticles1
//
//  Created by RRC on 5/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ShaderProcessor : NSObject

- (GLuint)BuildProgram:(const char*)vertexShaderSource with:(const char*)fragmentShaderSource;

@end
