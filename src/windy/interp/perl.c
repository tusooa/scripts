#include <EXTERN.h>
#include <perl.h>
#include <windows.h>
#include <stdio.h>
static PerlInterpreter *my_perl;  /***    The Perl interpreter    ***/
FILE * debugf;
int init();
int quit();

static void xs_init (pTHX);

extern void boot_DynaLoader (pTHX_ CV* cv);

extern void
xs_init(pTHX)
{
  char *file = __FILE__;
  /* DynaLoader is a special case */
  newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
}
BOOL APIENTRY DllMain( HINSTANCE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
          init();
          break;
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
          break;
	case DLL_PROCESS_DETACH:
          quit();
          break;
	}
	return TRUE;
}

int init()
{
  int num = 2;
  char *args[] = { "", "init.perl" };
  PERL_SYS_INIT3((int *)NULL,(char ***)NULL,(char ***)NULL);
  //PERL_SYS_INIT3(&num,&args,&env);
  my_perl = perl_alloc();
  perl_construct(my_perl);
  PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
  perl_parse(my_perl, xs_init, num, args, (char **)NULL);
  perl_run(my_perl);
  debugf = fopen("windy-dbg.txt", "a");
  return 1;
}

extern __declspec(dllexport) int perl_interp()
{
  return 1;
}

int quit()
{
  perl_destruct(my_perl);
  perl_free(my_perl);
  PERL_SYS_TERM();
  fprintf(debugf, "died.\n");
  fclose(debugf);
  return 1;
}

extern __declspec(dllexport) void set()
{
  dSP;
  SV *err_tmp;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("set", G_DISCARD|G_EVAL|G_NOARGS);
  SPAGAIN;
  err_tmp = ERRSV;
  if (SvTRUE(err_tmp)) {
    fprintf (debugf, "[error set]%s\n", SvPV_nolen(err_tmp));
    POPs;
  }
  PUTBACK;
  FREETMPS;                       /* free that return value        */
  LEAVE;                       /* ...and the XPUSHed "mortal" args.*/
  
}
extern __declspec(dllexport) void about()
{
  dSP;
  SV *err_tmp;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("about", G_DISCARD|G_EVAL|G_NOARGS);
  SPAGAIN;
  err_tmp = ERRSV;
  if (SvTRUE(err_tmp)) {
    fprintf (debugf, "[error about]%s\n", SvPV_nolen(err_tmp));
    POPs;
  }
  PUTBACK;
  FREETMPS;                       /* free that return value        */
  LEAVE;                       /* ...and the XPUSHed "mortal" args.*/
}
extern __declspec(dllexport) int end()
{
  dSP;
  SV *err_tmp;
  int retval;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("end", G_SCALAR|G_EVAL|G_NOARGS);
  SPAGAIN;
  err_tmp = ERRSV;
  if (SvTRUE(err_tmp)) {
    fprintf (debugf, "[error end]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = 1;
  } else {
    retval = POPi;
  }
  PUTBACK;
  FREETMPS;                       /* free that return value        */
  LEAVE;                       /* ...and the XPUSHed "mortal" args.*/
  return retval;
}
extern __declspec(dllexport) int EventFun(char *tencent, int type, int subtype, char *source, char *act, char *bep, char *msg, char *rawmsg, char *backptr)
{
  dSP;
  SV *err_tmp;
  int retval;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(sv_2mortal(newSVpv(tencent, 0)));
  XPUSHs(sv_2mortal(newSViv(type)));
  XPUSHs(sv_2mortal(newSViv(subtype)));
  XPUSHs(sv_2mortal(newSVpv(act, 0)));
  XPUSHs(sv_2mortal(newSVpv(bep, 0)));
  XPUSHs(sv_2mortal(newSVpv(msg, 0)));
  XPUSHs(sv_2mortal(newSVpv(rawmsg, 0)));
  XPUSHs(sv_2mortal(newSVpv(backptr, 0)));
  PUTBACK;
  call_pv("EventFun", G_SCALAR|G_EVAL);
  SPAGAIN;
  err_tmp = ERRSV;
  if (SvTRUE(err_tmp)) {
    fprintf (debugf, "[error EventFun]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = 0;
  } else {
    retval = POPi;
  }
  PUTBACK;
  FREETMPS;                       /* free that return value        */
  LEAVE;                       /* ...and the XPUSHed "mortal" args.*/
  return retval;
}
extern __declspec(dllexport) int Message(char *tencent, int type, char *rawmsg, char *cookie, char *sessionkey, char *clientkey)
{
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
    fprintf (debugf, "[error Message]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = 1;
  } else {
    retval = POPi;
  }
  PUTBACK;
  FREETMPS;                       /* free that return value        */
  LEAVE;                       /* ...and the XPUSHed "mortal" args.*/
  return retval;  
}
extern __declspec(dllexport) char * info()
{
  dSP;
  SV *err_tmp;
  char *retval;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  PUTBACK;
  call_pv("info", G_NOARGS|G_SCALAR|G_EVAL);
  SPAGAIN;
  err_tmp = ERRSV;
  if (SvTRUE(err_tmp)) {
    fprintf (debugf, "[error info]%s\n", SvPV_nolen(err_tmp));
    POPs;
    retval = "";
  } else {
    retval = POPp;
  }
  PUTBACK;
  FREETMPS;                       /* free that return value        */
  LEAVE;                       /* ...and the XPUSHed "mortal" args.*/
  return retval;  
}
