//
//  MainViewController.m
//  GLParticles1
//
//  Created by RRC on 5/2/13.
//  Copyright (c) 2013 Ricardo Rendon Cepeda. All rights reserved.
//

#import "MainViewController.h"
#import "EmitterTemplate.h"
#import "EmitterShader.h"

@interface MainViewController ()

// Properties
@property (strong) EmitterShader* emitterShader;

@end

@implementation MainViewController
{
    // Instance variables
    float   _timeCurrent;
    float   _timeMax;
    int     _timeDirection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up context
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // Set up view
    GLKView* view = (GLKView*)self.view;
    view.context = context;
    
    // Initialize variables
    _timeCurrent = 0.0f;
    _timeMax = 3.0f;
    _timeDirection = 1;
    
    // Load Shader
    [self loadShader];
    
    // Load Texture
    [self loadTexture:@"texture_32.png"];
    
    // Load Particle System
    [self loadParticles];
    [self loadEmitter];
}

#pragma mark - Load Shader

- (void)loadShader
{
    self.emitterShader = [[EmitterShader alloc] init];
    [self.emitterShader loadShader];
    glUseProgram(self.emitterShader.program);
}

#pragma mark - Load Texture

- (void)loadTexture:(NSString *)fileName
{
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],
                             GLKTextureLoaderOriginBottomLeft,
                             nil];
    
    NSError* error;
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if(texture == nil)
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    }
    
    glBindTexture(GL_TEXTURE_2D, texture.name);
}

#pragma mark - Load Particle System

- (float)randomFloatBetween:(float)min and:(float)max
{
    float range = max - min;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * range) + min;
}

- (void)loadParticles
{
    for(int i=0; i<NUM_PARTICLES; i++)
    {
        // Assign each particle its theta value (in radians)
        emitter.particles[i].theta = GLKMathDegreesToRadians(i);
        
        // Assign a random shade offset to each particle, for each RGB channel
        emitter.particles[i].shade[0] = [self randomFloatBetween:-0.25f and:0.25f];
        emitter.particles[i].shade[1] = [self randomFloatBetween:-0.25f and:0.25f];
        emitter.particles[i].shade[2] = [self randomFloatBetween:-0.25f and:0.25f];
    }
    
    // Create Vertex Buffer Object (VBO)
    GLuint particleBuffer = 0;
    glGenBuffers(1, &particleBuffer);                   // Generate particle buffer
    glBindBuffer(GL_ARRAY_BUFFER, particleBuffer);      // Bind particle buffer
    glBufferData(                                       // Fill bound buffer with particles
                 GL_ARRAY_BUFFER,                       // Buffer type (vertices/particles)
                 sizeof(emitter.particles),             // Buffer data size
                 emitter.particles,                     // Buffer data pointer
                 GL_STATIC_DRAW);                       // Data never changes
}

- (void)loadEmitter
{
    emitter.k = 4.0f;           // Constant k
    emitter.color[0] = 0.76f;   // Color: R
    emitter.color[1] = 0.12f;   // Color: G
    emitter.color[2] = 0.34f;   // Color: B
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Set the background color (green)
    glClearColor(0.30f, 0.74f, 0.20f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Set the blending function (normal w/ premultiplied alpha)
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Create Projection Matrix
    float aspectRatio = view.frame.size.width / view.frame.size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeScale(1.0f, aspectRatio, 1.0f);
    
    // Uniforms
    glUniformMatrix4fv(self.emitterShader.uProjectionMatrix, 1, 0, projectionMatrix.m);
    glUniform1f(self.emitterShader.uK, emitter.k);
    glUniform3f(self.emitterShader.uColor, emitter.color[0], emitter.color[1], emitter.color[2]);
    glUniform1f(self.emitterShader.uTime, (_timeCurrent/_timeMax));
    glUniform1i(self.emitterShader.uTexture, 0);
    
    // Attributes
    glEnableVertexAttribArray(self.emitterShader.aTheta);
    glVertexAttribPointer(self.emitterShader.aTheta,                // Set pointer
                          1,                                        // One component per particle
                          GL_FLOAT,                                 // Data is floating point type
                          GL_FALSE,                                 // No fixed point scaling
                          sizeof(Particles),                        // No gaps in data
                          (void*)(offsetof(Particles, theta)));     // Start from "theta" offset within bound buffer
    
    glEnableVertexAttribArray(self.emitterShader.aShade);
    glVertexAttribPointer(self.emitterShader.aShade,                // Set pointer
                          3,                                        // Three components per particle
                          GL_FLOAT,                                 // Data is floating point type
                          GL_FALSE,                                 // No fixed point scaling
                          sizeof(Particles),                        // No gaps in data
                          (void*)(offsetof(Particles, shade)));     // Start from "shade" offset within bound buffer
    
    // Draw particles
    glDrawArrays(GL_POINTS, 0, NUM_PARTICLES);
    glDisableVertexAttribArray(self.emitterShader.aTheta);
    glDisableVertexAttribArray(self.emitterShader.aShade);
}

- (void)update
{
    if(_timeCurrent > _timeMax)
        _timeDirection = -1;
    else if(_timeCurrent < 0.0f)
        _timeDirection = 1;
    
    _timeCurrent += _timeDirection * self.timeSinceLastUpdate;
}

@end
