OBJDIR=obj
BINDIR=bin
IMGUIDIR = imgui
EXECUTABLE = $(BINDIR)/listfiles

OBJS_FILES = imgui.o imgui_demo.o imgui_draw.o imgui_tables.o imgui_widgets.o
OBJS_FILES += imgui_impl_sdl2.o imgui_impl_opengl3.o
OBJS_FILES += listfiles.o
OBJS=$(OBJS_FILES:%=$(OBJDIR)/%)

CXX = g++
CXXFLAGS = -Wall -g -I$(IMGUIDIR) -I$(IMGUIDIR)/backends
LINUX_GL_LIBS = -lGL
LIBS =

##---------------------------------------------------------------------
## OPENGL ES
##---------------------------------------------------------------------

## This assumes a GL ES library available in the system, e.g. libGLESv2.so
# CXXFLAGS += -DIMGUI_IMPL_OPENGL_ES2
# LINUX_GL_LIBS = -lGLESv2
## If you're on a Raspberry Pi and want to use the legacy drivers,
## use the following instead:
# LINUX_GL_LIBS = -L/opt/vc/lib -lbrcmGLESv2

##---------------------------------------------------------------------
## BUILD FLAGS PER PLATFORM
##---------------------------------------------------------------------

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += $(LINUX_GL_LIBS) -ldl `sdl2-config --libs`

	CXXFLAGS += `sdl2-config --cflags`
	CFLAGS = $(CXXFLAGS)
endif

ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo `sdl2-config --libs`
	LIBS += -L/usr/local/lib -L/opt/local/lib

	CXXFLAGS += `sdl2-config --cflags`
	CXXFLAGS += -I/usr/local/include -I/opt/local/include
	CFLAGS = $(CXXFLAGS)
endif

ifeq ($(OS), Windows_NT)
    ECHO_MESSAGE = "MinGW"
    LIBS += -lgdi32 -lopengl32 -limm32 `pkg-config --static --libs sdl2`

    CXXFLAGS += `pkg-config --cflags sdl2`
    CFLAGS = $(CXXFLAGS)
endif

##---------------------------------------------------------------------
## BUILD RULES
##---------------------------------------------------------------------

$(EXECUTABLE): $(OBJS) $(BINDIR)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $(EXECUTABLE) $(LIBS)

$(OBJDIR)/%.o: %.cpp $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(IMGUIDIR)/%.cpp $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(IMGUIDIR)/backends/%.cpp $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

install:
	[ -d "$(IMGUIDIR)" ] || git clone https://github.com/ocornut/imgui.git
	cd "$(IMGUIDIR)" && git pull

all: $(BINDIR)/$(EXECUTABLE)
	@echo Build complete for $(ECHO_MESSAGE)

clean:
	rm -rf $(OBJDIR)\* $(BINDIR)\*