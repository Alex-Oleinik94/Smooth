//
// Landscape (with grass) demo
//
// Author: Alex V. Boreskoff <steps3d@gmail.com>, <steps3d@narod.ru>
//

#ifdef	_WIN32
	#pragma	warning (disable:4786)
#endif

#include	<list>
#include	<string>

#include    "libExt.h"

#ifdef	MACOSX
	#include	<GLUT/glut.h>
#else
	#include	<glut.h>
#endif

#include    <stdio.h>
#include    <stdlib.h>

#include    "libTexture.h"
#include    "TypeDefs.h"
#include    "Vector3D.h"
#include    "Vector2D.h"
#include    "boxes.h"
#include    "Camera.h"
#include	"BoundingBox.h"
#include	"Frustum.h"
#include	"noise.h"
#include	"GlslProgram.h"

using namespace std;
										// size of height map
#define	N1	128
#define	N2	128

Vector3D	vertex [N1][N2];			// vertices of a heightmap

struct	GrassVertex
{
	Vector3D	pos;
	Vector3D	tex;					// z component is stiffness
	Vector3D	refPoint;
};

struct	GrassObject
{
	Vector3D	point;					// ref point
	GrassVertex	vertex [4*3];
};

list<GrassObject *>	grass;

Vector3D    eye   ( 0, 0, 10 );  		// camera position
unsigned    decalMap;                   // decal (diffuse) texture
unsigned	grassMap;
unsigned    stoneMap;
unsigned    teapotMap;
unsigned	noiseMap;
float       angle     = 0;

float	yaw   = 0;
float	pitch = 0;
float	roll  = 0;

Camera			camera ( eye, 0, 0, 0 );	// camera to be used
Noise			noise;
GlslProgram 	program;
	
inline	float	rnd ()
{
	return (float) rand () / (float) RAND_MAX;
}

inline	float rnd ( float x1, float x2 )
{
	return x1 + (x2 - x1) * rnd ();
}

inline float	heightFunc ( float x, float y )
{
	return 5 * ( 1.0 + noise.noise ( 0.09375268*Vector3D ( x, y, 0.12387 ) ) );
}

void	adjustCameraHeight ()
{
	Vector3D	pos = camera.getPos ();
	
	pos.z = heightFunc ( pos.x, pos.y ) + 1.4;
	
	camera.moveTo ( pos );
}

void	initLandscape ()
{
	for ( int i = 0; i < N1; i++ )
		for ( int j = 0; j < N2; j++ )
		{
			vertex [i][j].x = i - 0.5 * N1;
			vertex [i][j].y = j - 0.5 * N2;
			vertex [i][j].z = heightFunc ( vertex [i][j].x, vertex [i][j].y );
		}
}

void	buildGrassBase ( float start, float r, float delta, Vector3D * tri, Vector3D * gr )
{
	for ( int i = 0; i < 3; i++ )
	{
		tri [i].x = r * cos ( start + i * M_PI * 2.0 / 3.0 );
		tri [i].y = r * sin ( start + i * M_PI * 2.0 / 3.0 );
		tri [i].z = 0;
	}
											// create grass base
	gr [0] = tri [0] - Vector3D ( 0, delta, 0 );
	gr [1] = tri [1] - Vector3D ( 0, delta, 0 );
	gr [2] = tri [1] + Vector3D ( delta, 0, 0 );
	gr [3] = tri [2] + Vector3D ( delta, 0, 0 );
	gr [4] = tri [2] + Vector3D ( 0, delta, 0 );
	gr [5] = tri [0] + Vector3D ( 0, delta, 0 );
}

void	initGrass ( float averageDist )
{
											// now fill with grass objects
	Vector3D	tri [3];					// triangle base (with respect to O)
	Vector3D	gr  [6];					// grass base
	float		r        = 1.0;
	float		delta    = 0.3*r;
	float		upScale  = 1.0;
	float		texStart = 0.0;
	Vector3D 	up ( 0, 0, r );
	int			count = 0;
	int			line  = 0;
											
	for ( float x0 = -0.5*N1; x0 < 0.5*N1; x0 += averageDist, line++ )
		for ( float y0 = -0.5*N2; y0 < 0.5*N2; y0 += averageDist )
		{
			float	x = x0 + ( rnd () - 0.5 ) * averageDist*1.2;
			float	y = y0 + ( rnd () - 0.5 ) * averageDist*1.2;
			
			if ( line & 1 )
				x += 0.5 * averageDist;
				
			if ( ((count++) % 17) == 0 )
				buildGrassBase ( rnd (), r, delta, tri, gr );
				
			Vector3D	  point  = Vector3D ( x, y, heightFunc ( x, y ) );
			GrassObject * object = new GrassObject;
				
//			texStart = 0.25*(rand () % 4);	
			up.x     = upScale*(rnd () - 0.5);
			up.y     = upScale*(rnd () - 0.5);
			
			object -> point = point;
			object -> vertex [0].pos = point + gr [0];
			object -> vertex [0].tex = Vector3D ( 0, 0, 0 );
			object -> vertex [1].pos = point + gr [1];
			object -> vertex [1].tex = Vector3D ( texStart + 0.25, 0, 0 );
			object -> vertex [2].pos = point + gr [1] + up;
			object -> vertex [2].tex = Vector3D ( texStart + 0.25, 1, 1 );
			object -> vertex [3].pos = point + gr [0] + up;
			object -> vertex [3].tex = Vector3D ( 0, 1, 1 );
	
//			texStart = 0.25*(rand () % 4);	
			up.x     = upScale*(rnd () - 0.5);
			up.y     = upScale*(rnd () - 0.5);
			
			object -> vertex [4].pos = point + gr [2];
			object -> vertex [4].tex = Vector3D ( 0, 0, 0 );
			object -> vertex [5].pos = point + gr [3]; 
			object -> vertex [5].tex = Vector3D ( texStart + 0.25, 0, 0 );
			object -> vertex [6].pos = point + gr [3] + up;
			object -> vertex [6].tex = Vector3D ( texStart + 0.25, 1, 1 );
			object -> vertex [7].pos = point + gr [2] + up;
			object -> vertex [7].tex = Vector3D ( 0, 1, 1 );
	
//			texStart = 0.25*(rand () % 4);	
			up.x     = upScale*(rnd () - 0.5);
			up.y     = upScale*(rnd () - 0.5);
			
			object -> vertex [8].pos  = point + gr [3];
			object -> vertex [8].tex  = Vector3D ( 0, 0, 0 );
			object -> vertex [9].pos  = point + gr [4];
			object -> vertex [9].tex  = Vector3D ( texStart + 0.25, 0, 0 );
			object -> vertex [10].pos = point + gr [4] + up;
			object -> vertex [10].tex = Vector3D ( texStart + 0.25, 1, 1 );
			object -> vertex [11].pos = point + gr [3] + up;
			object -> vertex [11].tex = Vector3D ( 0, 1, 1 );
			
			grass.push_back ( object );
		}
		
	printf ( "Created %d grass objects\n", grass.size () );
}
void	drawGrass ()
{
	glActiveTextureARB ( GL_TEXTURE1_ARB );
	glBindTexture      ( GL_TEXTURE_2D, noiseMap );
	glActiveTextureARB ( GL_TEXTURE0_ARB );
	glBindTexture      ( GL_TEXTURE_2D, grassMap );
	glEnable           ( GL_TEXTURE_2D );
	glEnable           ( GL_ALPHA_TEST );
	glAlphaFunc        ( GL_GEQUAL, 0.1 );
	
    program.bind ();

	for ( list<GrassObject *> :: iterator it = grass.begin (); it != grass.end (); ++it )
	{
		GrassObject * object = *it;
		
		glBegin            ( GL_QUADS );	
		glMultiTexCoord3fv ( GL_TEXTURE1_ARB, object -> point );
	
		for ( int k = 0; k < 12; k++ )
		{
			glTexCoord3fv ( object -> vertex [k].tex );
			glVertex3fv   ( object -> vertex [k].pos );
		}
	
		glEnd ();
	}

    program.unbind ();
	
	glDisable  ( GL_ALPHA_TEST );
}

void init ()
{
    glClearColor ( 0.0, 0.0, 0.0, 1.0 );
    glEnable     ( GL_DEPTH_TEST );
    glEnable     ( GL_TEXTURE_2D );
    glDepthFunc  ( GL_LEQUAL     );

    glHint ( GL_POLYGON_SMOOTH_HINT,         GL_NICEST );
    glHint ( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
}

void display ()
{
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

	glMatrixMode ( GL_MODELVIEW );
	glPushMatrix ();
	
	camera.apply ();

	glBindTexture ( GL_TEXTURE_2D, decalMap );
	glEnable      ( GL_TEXTURE_2D );
	
	glColor3f ( 1, 1, 1 );
	
	for ( int i = 0; i < N1 - 1; i++ )
		for ( int j = 0; j < N2 - 1; j++ )
		{
	      glBegin       ( GL_TRIANGLES );
			glTexCoord2f ( 0, 0 );
			glVertex3fv  ( vertex [i][j] );
			glTexCoord2f ( 1, 0 );
			glVertex3fv  ( vertex [i+1][j] );
			glTexCoord2f ( 1, 1 );
			glVertex3fv  ( vertex [i+1][j+1] );
	
			glTexCoord2f ( 0, 1 );
			glVertex3fv  ( vertex [i][j+1] );
			glTexCoord2f ( 1, 1 );
			glVertex3fv  ( vertex [i+1][j+1] );
			glTexCoord2f ( 0, 0 );
			glVertex3fv  ( vertex [i][j] );
	      glEnd ();
		}

	drawGrass ();
	
	glMatrixMode ( GL_MODELVIEW );
	glPopMatrix  ();
	
    glutSwapBuffers ();
}

void reshape ( int w, int h )
{
	camera.setViewSize ( w, h, 60 );
	camera.apply       ();
}

void key ( unsigned char key, int x, int y )
{
    if ( key == 27 || key == 'q' || key == 'Q' )        // quit requested
        exit ( 0 );
    else
   	if ( key == 'w' || key == 'W' )
   		camera.moveBy ( camera.getViewDir () * 0.2 );
   	else
   	if ( key == 'x' || key == 'X' )
   		camera.moveBy ( -camera.getViewDir () * 0.2 );
   	else
   	if ( key == 'a' || key == 'A' )
   		camera.moveBy ( -camera.getSideDir () * 0.2 );
   	else
   	if ( key == 'd' || key == 'D' )
   		camera.moveBy ( camera.getSideDir () * 0.2 );

	adjustCameraHe ight ();
   	glutPostRedisplay  ();
}

void    specialKey ( int key, int x, int y )
{
    if ( key == GLUT_KEY_UP )
        yaw += M_PI / 90;
    else
    if ( key == GLUT_KEY_DOWN )
        yaw -= M_PI / 90;
	else
    if ( key == GLUT_KEY_RIGHT )
        roll += M_PI / 90;
    else
    if ( key == GLUT_KEY_LEFT )
        roll -= M_PI / 90;

	camera.setEulerAngles ( yaw, pitch, roll );

    glutPostRedisplay ();
}

void	mouseFunc ( int x, int y )
{
	static	int	lastX = -1;
	static	int	lastY = -1;

	if ( lastX == -1 )				// not initialized
	{
		lastX = x;
		lastY = y;
	}

	yaw  -= (y - lastY) * 0.02;
	roll += (x - lastX) * 0.02;

	lastX = x;
	lastY = y;

	camera.setEulerAngles ( yaw, pitch, roll );

	glutPostRedisplay ();
}

void    animate ()
{
	static	float	lastTime = 0.0;
	float			time     = 0.001f * glutGet ( GLUT_ELAPSED_TIME );

    angle   += 2 * (time - lastTime);
    lastTime = time;

	program.bind   ();
	program.setUniformFloat  ( "time",   time );
	program.setUniformVector ( "eyePos", camera.getPos () );
	program.unbind ();

    glutPostRedisplay ();
}

int main ( int argc, char * argv [] )
{
                                // initialize glut
    glutInit            ( &argc, argv );
    glutInitDisplayMode ( GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH );
    glutInitWindowSize  ( 512, 512 );


                                // create window
    glutCreateWindow ( "OpenGL grass rendering demo" );

                                // register handlers
    glutDisplayFunc       ( display    );
    glutReshapeFunc       ( reshape    );
    glutKeyboardFunc      ( key        );
    glutSpecialFunc       ( specialKey );
    glutPassiveMotionFunc ( mouseFunc  );
    glutIdleFunc          ( animate    );

    init           ();
    initExtensions ();

    decalMap = createTexture2D ( true, "grasslayer.dds" );
	grassMap = createTexture2D ( true, "grassPack.dds"  );
	noiseMap = createTexture2D ( true, "noise.bmp"     );
	
	if ( !program.loadShaders ( "grass.vsh", "grass.fsh" ) )
	{
		printf ( "Error loading shaders:\n%s\n", program.getLog ().c_str () );

		return 3;
	}

    program.bind ();
    program.setTexture ( "grassMap",  0 );
	program.setTexture ( "noiseMap",  1 );
    program.unbind ();
	
	camera.setRightHanded ( false );

	initLandscape      ();
	initGrass          ( 0.42 );
	adjustCameraHeight ();
	
	printf ( "Starting\n" );

    glutMainLoop ();

    return 0;
}

