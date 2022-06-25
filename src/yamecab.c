#include <stdio.h>
#include <erl_driver.h>
#include <mecab.h>
#include <string.h>

#define CHECK(eval)                                           \
  if (!eval)                                                  \
  {                                                           \
    fprintf(stderr, "Exception:%s\n", mecab_strerror(mecab)); \
    mecab_destroy(mecab);                                     \
    exit(1);                                                  \
  }

typedef struct
{
  ErlDrvTermData port;
  mecab_model_t *model;
} yamecab_data;

static ErlDrvTermData atom_true;
static ErlDrvTermData atom_false;
static ErlDrvTermData atom_surface;
static ErlDrvTermData atom_feature;
static ErlDrvTermData atom_posid;
static ErlDrvTermData atom_stat;
static ErlDrvTermData atom_nor;
static ErlDrvTermData atom_unk;
static ErlDrvTermData atom_bos;
static ErlDrvTermData atom_eos;
static ErlDrvTermData atom_eon;
static ErlDrvTermData atom_best;
static ErlDrvTermData atom_alpha;
static ErlDrvTermData atom_beta;
static ErlDrvTermData atom_prob;
static ErlDrvTermData atom_wcost;
static ErlDrvTermData atom_cost;
static size_t map_size = 44;

static ErlDrvTermData stat_atom(unsigned char stat) 
{
  switch (stat)
  {
  case MECAB_NOR_NODE:
    return atom_nor;
  case MECAB_UNK_NODE:
    return atom_unk;
  case MECAB_BOS_NODE:
    return atom_bos;
  case MECAB_EOS_NODE:
    return atom_eos;
  case MECAB_EON_NODE:
    return atom_eon;
  }
  return atom_unk;
}

static void write_result(ErlDrvTermData *x, mecab_lattice_t *lattice, size_t len)
{
  const mecab_node_t *node = mecab_lattice_get_bos_node(lattice);
  int i = 0;
  for (; node; node = node->next)
  {
    x[i++] = ERL_DRV_ATOM; x[i++] = atom_surface;
    x[i++] = ERL_DRV_BUF2BINARY; x[i++] = (ErlDrvTermData)node->surface; x[i++] = node->length;

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_feature;
    x[i++] = ERL_DRV_BUF2BINARY; x[i++] = (ErlDrvTermData)node->feature; x[i++] = strlen(node->feature);

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_posid;
    x[i++] = ERL_DRV_UINT; x[i++] = (ErlDrvTermData)node->posid;

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_stat;
    x[i++] = ERL_DRV_ATOM; x[i++] = stat_atom(node->stat);

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_best;
    x[i++] = ERL_DRV_ATOM; x[i++] = node->isbest ? atom_true : atom_false;

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_alpha;
    x[i++] = ERL_DRV_FLOAT; x[i++] = (ErlDrvTermData)(&node->alpha);

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_beta;
    x[i++] = ERL_DRV_FLOAT; x[i++] = (ErlDrvTermData)(&node->beta);

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_prob;
    x[i++] = ERL_DRV_FLOAT; x[i++] = (ErlDrvTermData)(&node->prob);

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_wcost;
    x[i++] = ERL_DRV_INT; x[i++] = node->wcost;

    x[i++] = ERL_DRV_ATOM; x[i++] = atom_cost;
    x[i++] = ERL_DRV_INT; x[i++] = node->cost;

    x[i++] = ERL_DRV_MAP; x[i++] = 10;
  }
  x[i++] = ERL_DRV_NIL;
  x[i++] = ERL_DRV_LIST; x[i++] = len + 1;
}

static ErlDrvData yamecab_start(ErlDrvPort port, char *buff)
{
  mecab_model_t *model;
  model = mecab_model_new2("");
  if (!model)
  {
    return ERL_DRV_ERROR_GENERAL;
  }

  yamecab_data *d = (yamecab_data *)driver_alloc(sizeof(yamecab_data));
  d->port = driver_mk_port(port);
  d->model = model;
  return (ErlDrvData)d;
}

static void yamecab_stop(ErlDrvData handle)
{
  yamecab_data *d = (yamecab_data *)handle;
  if (d->model)
    mecab_model_destroy(d->model);
  driver_free((char *)handle);
}

static void yamecab_output(ErlDrvData handle, char *buff,
                           ErlDrvSizeT bufflen)
{
  yamecab_data *d = (yamecab_data *)handle;

  mecab_t *mecab;
  mecab_lattice_t *lattice;
  ErlDrvTermData *result;

  mecab = mecab_model_new_tagger(d->model);
  CHECK(mecab);

  lattice = mecab_model_new_lattice(d->model);
  CHECK(lattice);

  mecab_lattice_set_sentence(lattice, buff);
  mecab_parse_lattice(mecab, lattice);

  const mecab_node_t *node = mecab_lattice_get_bos_node(lattice);
  size_t len = 0;
  for (; node; node = node->next)
    len++;

  const size_t result_len = 3 + map_size * len;
  result = (ErlDrvTermData *)driver_alloc(sizeof(ErlDrvTermData) * result_len);

  write_result(result, lattice, len);
  erl_drv_output_term(d->port, result, result_len);

  driver_free(result);
  mecab_destroy(mecab);
  mecab_lattice_destroy(lattice);
}

ErlDrvEntry yamecab_driver_entry = {
    NULL,                           /* F_PTR init, called when driver is loaded */
    yamecab_start,                  /* L_PTR start, called when port is opened */
    yamecab_stop,                   /* F_PTR stop, called when port is closed */
    yamecab_output,                 /* F_PTR output, called when erlang has sent */
    NULL,                           /* F_PTR ready_input, called when input descriptor ready */
    NULL,                           /* F_PTR ready_output, called when output descriptor ready */
    "yamecab",                      /* char *driver_name, the argument to open_port */
    NULL,                           /* F_PTR finish, called when unloaded */
    NULL,                           /* void *handle, Reserved by VM */
    NULL,                           /* F_PTR control, port_command callback */
    NULL,                           /* F_PTR timeout, reserved */
    NULL,                           /* F_PTR outputv, reserved */
    NULL,                           /* F_PTR ready_async, only for async drivers */
    NULL,                           /* F_PTR flush, called when port is about
               to be closed, but there is data in driver
               queue */
    NULL,                           /* F_PTR call, much like control, sync call
               to driver */
    NULL,                           /* unused */
    ERL_DRV_EXTENDED_MARKER,        /* int extended marker, Should always be
               set to indicate driver versioning */
    ERL_DRV_EXTENDED_MAJOR_VERSION, /* int major_version, should always be
               set to this value */
    ERL_DRV_EXTENDED_MINOR_VERSION, /* int minor_version, should always be
               set to this value */
    0,                              /* int driver_flags, see documentation */
    NULL,                           /* void *handle2, reserved for VM use */
    NULL,                           /* F_PTR process_exit, called when a
               monitored process dies */
    NULL                            /* F_PTR stop_select, called to close an
               event object */
};

DRIVER_INIT(yamecab) /* must match name in driver_entry */
{
  atom_true = driver_mk_atom("true");
  atom_false = driver_mk_atom("false");
  atom_surface = driver_mk_atom("surface");
  atom_feature = driver_mk_atom("feature");
  atom_posid = driver_mk_atom("posid");
  atom_stat = driver_mk_atom("stat");
  atom_nor = driver_mk_atom("nor");
  atom_unk = driver_mk_atom("unk");
  atom_bos = driver_mk_atom("bos");
  atom_eos = driver_mk_atom("eos");
  atom_eon = driver_mk_atom("eon");
  atom_best = driver_mk_atom("best");
  atom_alpha = driver_mk_atom("alpha");
  atom_beta = driver_mk_atom("beta");
  atom_prob = driver_mk_atom("prob");
  atom_wcost = driver_mk_atom("wcost");
  atom_cost = driver_mk_atom("cost");

  return &yamecab_driver_entry;
}
