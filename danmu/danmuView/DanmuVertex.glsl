attribute vec4 Position;
attribute vec4 sourceColor;
varying vec4 DestinationColor;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

uniform mat4 gModel;
uniform mat4 gWorld;

void main(void){
    DestinationColor = sourceColor;
    gl_Position = gWorld*gModel*Position;
    TexCoordOut = TexCoordIn;
}
