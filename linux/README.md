# Configuring a Replicate Linux Host 

It is a straightforward process configure Qlik Replicate installed on a Linux host.
There are just a few steps:

* Install the Yellowbrick tools package.
* Install the `ybload.sh` script in the Qlik Replicate `bin` directory. 
* Upload a new provider syntax for PostgreSQL that addresses the differences that
Yellowbrick has from vanilla PostgreSQL.

## Install the Yellowbrick Tools Package

Once you have downloaded the Yellowbrick tools from Yellowbrick to the Replicate
host, install the package as follows (note that the package name may vary):

```
#> yum -y install /path/to/ybtools-5.2.11-220208194834.el7.x86_64.rpm

```

By default, the *ybtools* package will be installed at */opt/ybtools*.

> Note: `ybload` has a dependency on Java 1.8. If it is not already installed on 
> your system, you will need to install it now. Be sure that you also set
> `JAVA_HOME` as appropriate in your environment so that `ybload.sh` will pick it up.

## Install ybload.sh 

Next, we need to copy the `ybload.sh` script into the Qlik Replicate *bin* directory. 
If you took the defaults when installing Qlik Replicate, the *bin* directory is located
at `/opt/attunity/replicate/bin`.

## Upload a new provider syntax for PostgreSQL

Finally, we need to upload a new version of the provider syntax for PostgreSQL that is
specific to Yellowbrick. Unlike with Qlik Replicate for Windows, on Linux we will be
**physically replacing** the PostgreSQL provider syntax rather than installing a new provider
syntax next to it. 

> Be aware that installing this provider syntax will physically replace the provider
> syntax for PostgreSQL. If you intend to have other PostgreSQL-based targets for Qlik
> Replicate, you will need to serve them from another Qlik Replicate server.

First, you need to copy the *PostgreSQLLinux-ybload.json* file to the Replicate *data*
directory. By default, the Replicate *data* directory can be found at */opt/attunity/replicate/data*, 
but customers frequently place the data directory elsewhere. The examples below specify the
location of the Replicate *data* directory. If you have left it in default location,
you can safely omit the `-d <directory>` option below.

> Note: be sure that you do **not** include the `.json` suffix when you specify the 
> file name below.


```
#> repctl -d /data putobject data=PostgreSQLLinux-ybload
[putobject command] Succeeded
#>
```

Finally, double check to be sure that Replicate successfully replaced the *PostgreSQLLinux*
provider syntax by retrieving it here and examining the contents to ensure that
`ybload.sh` is specified.


```
#> repctl -d /data getprovidersyntax syntax_name=PostgreSQLLinux
command getprovidersyntax response:
{
	"provider_syntax":	{
		"name":	"PostgreSQLLinux",
		"query_syntax":	{
			"create_primary_key":	"ALTER TABLE ${QO}${TABLE_OWNER}${QC}.${QO}${TABLE_NAME}${QC} ADD PRIMARY KEY ( ${COLUMN_LIST} )",
			"modify_column":	"ALTER TABLE ${QO}${TABLE_OWNER}${QC}.${QO}${TABLE_NAME}${QC} ALTER COLUMN ${QO}${COLUMN_NAME}${QC} SET DATA TYPE ${COLUMN_TYPE}",
			"error_code_constraint_violation":	"23000,23502,23505",
			"error_code_data_failure":	"22P02",
			"bulk_update_syntax":	"FROM_AT_THE_END",
			"csv_null_value":	"attNULL",
			"load_data_exe_name":	"ybload.sh",
        &hellip;
}
[getprovidersyntax command] Succeeded
#> 
```

