#include <stdio.h>
#include <erl_driver.h>
#include <mecab.h>
#include <string.h>

#define CHECK(eval) if (! eval) { \
    fprintf (stderr, "Exception:%s\n", mecab_strerror (mecab)); \
    mecab_destroy(mecab); \
    exit(1); }

typedef struct {
    ErlDrvPort port;
} yamecab_data;

char foo(char arg) {
  return 0;
}

static ErlDrvData yamecab_start(ErlDrvPort port, char *buff)
{
    yamecab_data* d = (yamecab_data*)driver_alloc(sizeof(yamecab_data));
    d->port = port;
    return (ErlDrvData)d;
}

static void yamecab_stop(ErlDrvData handle)
{
    driver_free((char*)handle);
}

static void yamecab_output(ErlDrvData handle, char *buff,
			       ErlDrvSizeT bufflen)
{
    yamecab_data* d = (yamecab_data*)handle;

    mecab_t *mecab;
    const mecab_node_t *node;
    char *result;
    int i;
    size_t len;

    mecab = mecab_new2("");
    CHECK(mecab);

    result = mecab_sparse_tostr(mecab, buff);
    CHECK(result)

    driver_output(d->port, result, strlen(result));
}

ErlDrvEntry yamecab_driver_entry = {
    NULL,			/* F_PTR init, called when driver is loaded */
    yamecab_start,		/* L_PTR start, called when port is opened */
    yamecab_stop,		/* F_PTR stop, called when port is closed */
    yamecab_output,		/* F_PTR output, called when erlang has sent */
    NULL,			/* F_PTR ready_input, called when input descriptor ready */
    NULL,			/* F_PTR ready_output, called when output descriptor ready */
    "yamecab",		/* char *driver_name, the argument to open_port */
    NULL,			/* F_PTR finish, called when unloaded */
    NULL,                       /* void *handle, Reserved by VM */
    NULL,			/* F_PTR control, port_command callback */
    NULL,			/* F_PTR timeout, reserved */
    NULL,			/* F_PTR outputv, reserved */
    NULL,                       /* F_PTR ready_async, only for async drivers */
    NULL,                       /* F_PTR flush, called when port is about
				   to be closed, but there is data in driver
				   queue */
    NULL,                       /* F_PTR call, much like control, sync call
				   to driver */
    NULL,                       /* unused */
    ERL_DRV_EXTENDED_MARKER,    /* int extended marker, Should always be
				   set to indicate driver versioning */
    ERL_DRV_EXTENDED_MAJOR_VERSION, /* int major_version, should always be
				       set to this value */
    ERL_DRV_EXTENDED_MINOR_VERSION, /* int minor_version, should always be
				       set to this value */
    0,                          /* int driver_flags, see documentation */
    NULL,                       /* void *handle2, reserved for VM use */
    NULL,                       /* F_PTR process_exit, called when a
				   monitored process dies */
    NULL                        /* F_PTR stop_select, called to close an
				   event object */
};

DRIVER_INIT(yamecab) /* must match name in driver_entry */
{
    return &yamecab_driver_entry;
}


