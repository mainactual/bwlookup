/*=========================================================================
 *
 *  Copyright mainactual
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *=========================================================================*/
#include <iostream>
#include "opencv2\core\core.hpp"
#include "opencv2\imgproc\imgproc.hpp"
#include "opencv2\highgui\highgui.hpp"

void bwlookup( const cv::Mat & in, cv::Mat & out, const cv::Mat & lut, int bordertype=cv::BORDER_CONSTANT, cv::Scalar px = cv::Scalar(0) ) 
{
	if ( in.type() != CV_8UC1 )
		CV_Error(CV_StsError, "er");
	if ( lut.type() != CV_8UC1 || lut.rows*lut.cols!=512 || !lut.isContinuous() )
		CV_Error(CV_StsError, "lut size != 512" );
	if ( out.type() != in.type() || out.size() != in.size() )
		out = cv::Mat( in.size(), in.type() );

	const unsigned char * _lut = lut.data;
	cv::Mat t;
	cv::copyMakeBorder( in,t,1,1,1,1,bordertype,px);
	const int rows=in.rows+1;
	const int cols=in.cols+1;
	for ( int y=1;y<rows;++y)
	{
		for ( int x=1;x<cols;++x)
		{
			int L = 0;
			const int jmax=y+1;
#if 0 // row-major order
			for ( int j=y-1, k=1; j<=jmax; ++j, k<<=3 )
			{
				const unsigned char * p = t.ptr<unsigned char>(j) + x-1;
				for ( unsigned int u=0;u<3;++u )
				{
					if ( p[u] )
						L += (k<<u);
#else // column-major order (MATLAB)
				for ( int j=y-1, k=1; j<=jmax; ++j, k<<=1 )
				{
					const unsigned char * p = t.ptr<unsigned char>(j) + x-1;
					for ( unsigned int u=0;u<3;++u )
					{
						if ( p[u] )
							L += (k<<3*u);
#endif
				}
			}
			out.at<unsigned char>(y-1,x-1)=_lut[ L ];
		}
	}
}
void mainactual( int argc, char * argv[] )
{
	if ( argc != 4 )
		CV_Error(CV_StsError, "argc!=4");
	cv::Mat input = cv::imread( argv[1], CV_LOAD_IMAGE_GRAYSCALE );
	cv::Mat lut = cv::imread( argv[2], CV_LOAD_IMAGE_GRAYSCALE );
	cv::Mat output;
	bwlookup( input, output, lut );
	cv::imwrite( argv[3], output );
}
int main( int argc, char * argv[] )
{
	try {
		mainactual( argc, argv );
	}catch ( std::exception & e )
	{
		std::cout << e.what() << std::endl;
		return -1;
	}
	return 0;
}
