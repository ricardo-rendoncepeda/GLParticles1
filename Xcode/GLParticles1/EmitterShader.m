//
//  EmitterShader.m
//  GLParticles1
//
//  Created by RRC on 5/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "EmitterShader.h"
#import "ShaderProcessor.h"

// Shaders
#define STRINGIFY(A) #A
#include "Emitter.vsh"
#include "Emitter.fsh"

@implementation EmitterShader

- (void)loadShader
{
    // Program
    ShaderProcessor* shaderProcessor = [[ShaderProcessor alloc] init];
    self.program = [shaderProcessor BuildProgram:EmitterVS with:EmitterFS];
    
    // Attributes
    self.aTheta = glGetAttribLocation(self.program, "aTheta");
    self.aShade = glGetAttribLocation(self.program, "aShade");
    
    // Uniforms
    self.uProjectionMatrix = glGetUniformLocation(self.program, "uProjectionMatrix");
    self.uTime = glGetUniformLocation(self.program, "uTime");
    self.uTexture = glGetUniformLocation(self.program, "uTexture");
    self.uK = glGetUniformLocation(self.program, "uK");
    self.uColor = glGetUniformLocation(self.program, "uColor");
}

@end
