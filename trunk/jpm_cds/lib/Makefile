
CXX = g++ -m32

CXXFLAGS = 

COMPILE = $(CXX) $(CXXFLAGS) -c 

LIBS = libir_curve.so
all: $(LIBS)

libir_curve.so: ../objects/ir_curve.c ../gen/objects/ir_curve_wrapper.c
	g++ -m32 -shared -Wl,-soname,libir_curve.so -o libir_curve.so $(TRAD4_ROOT)/objects/sqlite3.o ../objects/ir_curve.o ../objects/jpm_objects/badday.o ../objects/jpm_objects/bsearch.o ../objects/jpm_objects/buscache.o ../objects/jpm_objects/busday.o ../objects/jpm_objects/cashflow.o ../objects/jpm_objects/cdsbootstrap.o ../objects/jpm_objects/cds.o ../objects/jpm_objects/cdsone.o ../objects/jpm_objects/cerror.o ../objects/jpm_objects/cfileio.o ../objects/jpm_objects/cfinanci.o ../objects/jpm_objects/cmemory.o ../objects/jpm_objects/contingentleg.o ../objects/jpm_objects/convert.o ../objects/jpm_objects/cxbsearch.o ../objects/jpm_objects/cxdatelist.o ../objects/jpm_objects/cx.o ../objects/jpm_objects/cxzerocurve.o ../objects/jpm_objects/dateadj.o ../objects/jpm_objects/dateconv.o ../objects/jpm_objects/datelist.o ../objects/jpm_objects/date_sup.o ../objects/jpm_objects/dtlist.o ../objects/jpm_objects/feeleg.o ../objects/jpm_objects/fltrate.o ../objects/jpm_objects/gtozc.o ../objects/jpm_objects/interpc.o ../objects/jpm_objects/ldate.o ../objects/jpm_objects/linterpc.o ../objects/jpm_objects/lintrp1.o ../objects/jpm_objects/lprintf.o ../objects/jpm_objects/lscanf.o ../objects/jpm_objects/rtbrent.o ../objects/jpm_objects/schedule.o ../objects/jpm_objects/streamcf.o ../objects/jpm_objects/strutil.o ../objects/jpm_objects/stub.o ../objects/jpm_objects/tcurve.o ../objects/jpm_objects/timeline.o ../objects/jpm_objects/version.o ../objects/jpm_objects/yearfrac.o ../objects/jpm_objects/zcall.o ../objects/jpm_objects/zcswap.o ../objects/jpm_objects/zcswdate.o ../objects/jpm_objects/zcswutil.o ../objects/jpm_objects/zerocurve.o ../objects/jpm_objects/zr2coup.o ../objects/jpm_objects/zr2fwd.o


clean:
	rm -f $(LIBS)

