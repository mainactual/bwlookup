PROJECT(mylookup)

CMAKE_MINIMUM_REQUIRED( VERSION 2.6 )

#
# Open Computer Vision required!
#
FIND_PACKAGE(OpenCV)
IF (NOT OpenCV_FOUND )
	MESSAGE(FATAL_ERROR "Package OpenCV not found.")
ENDIF()


SET(SRCS
	main.cpp
)

ADD_EXECUTABLE(mylookup ${SRCS} )	

SET(LIBS
	${OpenCV_LIBRARIES}
)
TARGET_LINK_LIBRARIES(mylookup ${LIBS} )
