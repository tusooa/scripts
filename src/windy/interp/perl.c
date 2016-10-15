#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include <windows.h>
#include <stdio.h>
#ifndef INIT_FILE
#define INIT_FILE "init.perl"
#endif
static PerlInterpreter *my_perl = NULL;
#define EXTERN_C extern

EXTERN_C void xs_init (pTHX);

EXTERN_C void boot_DynaLoader (pTHX_ CV* cv);
EXTERN_C void boot_Win32CORE (pTHX_ CV* cv);

EXTERN_C void
xs_init(pTHX)
{
    static const char file[] = __FILE__;
    dXSUB_SYS;
    PERL_UNUSED_CONTEXT;

    /* DynaLoader is a special case */
    newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
    newXS("Win32CORE::bootstrap", boot_Win32CORE, file);
}
/*BOOL APIENTRY DllMain( HINSTANCE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
  switch (ul_reason_for_call) {
  case DLL_PROCESS_ATTACH:
    //printf("init\n");
    //init();
    break;
  case DLL_THREAD_ATTACH:
    break;
  case DLL_THREAD_DETACH:
    printf("thread-detach\n");
    break;
  case DLL_PROCESS_DETACH:
    printf("process-detach\n");
    quit();
    printf("ended\n");
    break;
  }
  return TRUE;
  }*/

static __attribute__((constructor)) void init()
{
  int num = 2;
  char *args[] = { "", INIT_FILE };
  PERL_SYS_INIT3((int *)NULL,(char ***)NULL,(char ***)NULL);
  my_perl = perl_alloc();
  perl_construct(my_perl);
  PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
  perl_parse(my_perl, xs_init, num, args, (char **)NULL);
  perl_run(my_perl);
}

static __attribute__((destructor)) void quit()
{
  if (my_perl) {
    PERL_SET_CONTEXT(my_perl);
    PL_perl_destruct_level = 1;
    perl_destruct(my_perl);
    perl_free(my_perl);
    PERL_SYS_TERM();
  }
}

extern __declspec(dllexport) void set()
{
  PERL_SET_CONTEXT(my_perl);
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("set", G_VOID|G_EVAL|G_NOARGS);
  SPAGAIN;
  if (SvTRUE(ERRSV)) {
    //fprintf (debugf, "[error set]%s\n", SvPV_nolen(err_tmp));
    POPs;
  }
  PUTBACK;
  FREETMPS;
  LEAVE;
  
}
extern __declspec(dllexport) void about()
{
  PERL_SET_CONTEXT(my_perl);
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("about", G_VOID|G_EVAL|G_NOARGS);
  SPAGAIN;
  if (SvTRUE(ERRSV)) {
    POPs;
  }
  PUTBACK;
  FREETMPS;
  LEAVE;
}
extern __declspec(dllexport) int end()
{
  PERL_SET_CONTEXT(my_perl);
  dSP;
  int retval;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("end", G_SCALAR|G_EVAL|G_NOARGS);
  SPAGAIN;
  if (SvTRUE(ERRSV)) {
    //fprintf (debugf, "[error end]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = 1;
  } else {
    retval = POPi;
  }
  PUTBACK;
  FREETMPS;
  LEAVE;
  return retval;
}
extern __declspec(dllexport) int EventFun(char *tencent, int type, int subtype, char *source, char *act, char *bep, char *msg, char *rawmsg, int backptr)
{
  if (type == -1) { //undefined
    return 0;
  }
  PERL_SET_CONTEXT(my_perl);
  //fprintf(debugf, "EventFun %s\n", msg);
  dSP;
  int count;
  int retval;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSVpv(tencent, 0)));
  XPUSHs(sv_2mortal(newSViv(type)));
  XPUSHs(sv_2mortal(newSViv(subtype)));
  XPUSHs(sv_2mortal(newSVpv(source, 0)));
  XPUSHs(sv_2mortal(newSVpv(act, 0)));
  XPUSHs(sv_2mortal(newSVpv(bep, 0)));
  XPUSHs(sv_2mortal(newSVpv(msg, 0)));
  XPUSHs(sv_2mortal(newSVpv(rawmsg, 0)));
  //XPUSHs(sv_2mortal(newSVpv(backptr, 0)));
  PUTBACK;
  count = call_pv("EventFun", G_SCALAR|G_EVAL);
  SPAGAIN;
  if (count != 1) {
    retval = 0; // big trouble
  } else if (SvTRUE(ERRSV)) {
    //fprintf (debugf, "[error EventFun]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = 0;
  } else {
    retval = POPi;
  }
  PUTBACK;
  FREETMPS;
  LEAVE;
  return retval;
}

/*extern __declspec(dllexport) int Message(char *tencent, int type, char *rawmsg, char *cookie, char *sessionkey, char *clientkey)
{
  PERL_SET_CONTEXT(my_perl);
  dSP;
  SV *err_tmp;
  int retval;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSVpv(tencent, 0)));
  XPUSHs(sv_2mortal(newSViv(type)));
  XPUSHs(sv_2mortal(newSVpv(rawmsg, 0)));
  XPUSHs(sv_2mortal(newSVpv(cookie, 0)));
  XPUSHs(sv_2mortal(newSVpv(sessionkey, 0)));
  XPUSHs(sv_2mortal(newSVpv(clientkey, 0)));
  PUTBACK;
  call_pv("Message", G_SCALAR|G_EVAL);
  SPAGAIN;
  err_tmp = ERRSV;
  if (SvTRUE(err_tmp)) {
    //fprintf (debugf, "[error Message]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = 1;
  } else {
    retval = POPi;
  }
  PUTBACK;
  FREETMPS;
  LEAVE;
  return retval;  
  }*/
extern __declspec(dllexport) char * info()
{
  PERL_SET_CONTEXT(my_perl);
  dSP;
  char *retval;
  int count;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  count = call_pv("info", G_NOARGS|G_SCALAR|G_EVAL);
  SPAGAIN;
  if (count != 1) {
    retval = "big trouble";
  } else if (SvTRUE(ERRSV)) {
    //fprintf (debugf, "[error info]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = "[ERROR]";
  } else {
    retval = POPp;
  }
  PUTBACK;
  FREETMPS;
  LEAVE;
  return retval;  
}

