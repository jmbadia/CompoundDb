% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CompDb.R, R/CompDb-methods.R
\name{CompDb}
\alias{CompDb}
\alias{CompDb-class}
\alias{show}
\alias{dbconn,CompDb-method}
\alias{show,CompDb-method}
\alias{compoundVariables}
\alias{hasMsMsSpectra}
\alias{src_compdb}
\alias{tables}
\alias{Spectra,CompDb-method}
\alias{supportedFilters,CompDb-method}
\alias{metadata,CompDb-method}
\alias{spectraVariables,CompDb-method}
\alias{compoundVariables,CompDb-method}
\alias{compounds,CompDb-method}
\title{Simple compound (metabolite) databases}
\usage{
CompDb(x, flags = RSQLite::SQLITE_RO)

hasMsMsSpectra(x)

src_compdb(x)

tables(x)

\S4method{dbconn}{CompDb}(x)

\S4method{Spectra}{CompDb}(object, columns = spectraVariables(object), filter, ...)

\S4method{supportedFilters}{CompDb}(object)

\S4method{metadata}{CompDb}(x, ...)

\S4method{spectraVariables}{CompDb}(object, ...)

\S4method{compoundVariables}{CompDb}(object, includeId = FALSE, ...)

\S4method{compounds}{CompDb}(
  object,
  columns = compoundVariables(object),
  filter,
  return.type = c("data.frame", "tibble"),
  ...
)
}
\arguments{
\item{x}{For \code{CompDb}: \code{character(1)} with the file name of the SQLite
compound database. Alternatively it is possible to provide the connection
to the database with parameter \code{x}.\preformatted{For all other methods: a `CompDb` object.
}}

\item{flags}{flags passed to the SQLite database connection.
See \code{\link[=SQLite]{SQLite()}}. Defaults to read-only, i.e. \code{RSQLite::SQLITE_RO}.}

\item{object}{For all methods: a \code{CompDb} object.}

\item{columns}{For \code{compounds}, \code{Spectra}: \code{character} with the names of the
database columns that should be retrieved. Use \code{compoundVariables} and/or
\code{spectraVariables} for a list of available column names.}

\item{filter}{For \code{compounds} and \code{Spectra}: filter expression or
\code{\link[=AnnotationFilter]{AnnotationFilter()}} defining a filter to be used to retrieve specific
elements from the database.}

\item{...}{additional arguments. Currently not used.}

\item{includeId}{for \code{compoundVariables}: \code{logical(1)} whether the comound
ID (column \code{"compound_id"}) should be included in the result. The
default is \code{includeIds = FALSE}.}

\item{return.type}{For \code{compounds}: either \code{"data.frame"} or \code{"tibble"} to
return the result as a \code{\link[=data.frame]{data.frame()}} or \code{\link[=tibble]{tibble()}}, respectively.}
}
\description{
\code{CompDb} objects provide access to general (metabolite) compound
annotations along with \emph{metadata} information such as the annotation's
source, date and release version. The data is stored internally in a
database (usually an SQLite database).

\code{hasMsMsSpectra} returns \code{TRUE} if MS/MS spectrum data is
available in the database and \code{FALSE} otherwise.
}
\details{
\code{CompDb} objects should be created using the constructor function
\code{CompDb} providing the name of the (SQLite) database file providing
the compound annotation data.
}
\section{Retrieve annotations from the database}{


Annotations/compound informations can be retrieved from a \code{CompDb} database
with the \code{compounds} and \code{Spectra} functions:
\itemize{
\item \code{compounds} extracts compound data from the \code{CompDb} object. In contrast
to \code{src_compdb} it returns the actual data as a \code{data.frame} (if
\code{return.type = "data.frame"}) or a \code{\link[tibble:tibble]{tibble::tibble()}} (if
\code{return.type = "tibble"}). A \code{compounds} call will always return all
elements from the \emph{ms_compound} table (unless a \code{filter} is used).
\item \code{Spectra} extract spectra from the database and returns them as a
\code{\link[=Spectra]{Spectra()}} object from the \code{Spectra} package. Additional annotations
requested with the \code{columns} parameter are added as additional spectra
variables.
}
}

\section{General functions}{

\itemize{
\item \code{CompDb}: connect to a compound database.
\item \code{compoundVariables}: returns all available columns/database fields for
compounds.
\item \code{dbconn}: returns the connection (of type \code{DBIConnection}) to the database.
\item \code{metadata}: returns general meta data of the compound database.
\item \code{spectraVariables}: returns all spectra variables (i.e. columns) available
in the \code{CompDb}.
\item \code{src_compdb} provides access to the \code{CompDb}'s database \emph{via}
the functionality from the \code{dplyr}/\code{dbplyr} package.
\item \code{supportedFilters}: provides an overview of the filters that can be
applied on a \code{CompDb} object to extract only specific data from the
database.
\item \code{tables}: returns a named \code{list} (names being table names) with
the fields/columns from each table in the database.
}
}

\section{Filtering the database}{


Data access methods such as \code{compounds} and \code{Spectra} allow to filter the
results using specific filter classes and expressions. Filtering uses the
concepts from Bioconductor's \code{AnnotationFilter} package. All information
for a certain compound with the ID \code{"HMDB0000001"} can for example be
retrieved by passing the filter expression
\code{filter = ~ compound_id == "HMDB0000001"} to the \code{compounds} function.

Use the \link{supportedFilters} function on the \link{CompDb} object to get a list of
all supported filters. See also examples below or the usage vignette for
details.
}

\examples{

## We load a small compound test database based on MassBank which is
## distributed with this package.
cdb <- CompDb(system.file("sql/CompDb.MassBank.sql", package = "CompoundDb"))
cdb

## Get general metadata information from the database, such as originating
## source and version:
metadata(cdb)

## List all available compound annotations/fields
compoundVariables(cdb)

## Extract a data.frame with these annotations for all compounds
compounds(cdb)

## Add also the synonyms (aliases) for the compounds. This will cause the
## tables compound and synonym to be joined. The elements of the compound_id
## and name are now no longer unique
res <- compounds(cdb, columns = c("name", "synonym"))
head(res)

## List all database tables and their columns
tables(cdb)

## Any of these columns can be used in the `compounds` call to retrieve
## the specific annotations. The corresponding database tables will then be
## joined together
compounds(cdb, columns = c("formula", "publication"))

## Create a Spectra object with all MS/MS spectra from the database.
sps <- Spectra(cdb)
sps

## Extract spectra for a specific compound.
sps <- Spectra(cdb, filter = ~ name == "Mellein")
sps

## List all available annotations for MS/MS spectra
spectraVariables(sps)

## Get access to the m/z values of these
mz(sps)

library(Spectra)
## Plot the first spectrum
plotSpectra(sps[1])


#########
## Filtering the database
##
## Get all compounds with an exact mass between 310 and 320
res <- compounds(cdb, filter = ~ exactmass > 310 & exactmass < 320)
res

## Get all compounds that have an H14 in their formula.
res <- compounds(cdb, filter = FormulaFilter("H14", "contains"))
res

#########
## Using CompDb with the *tidyverse*
##
## Using return.type = "tibble" the result will be returned as a "tibble"
compounds(cdb, return.type = "tibble")

## Use the CompDb in a dplyr setup
library(dplyr)
src_cmp <- src_compdb(cdb)
src_cmp

## Get a tbl for the ms_compound table
cmp_tbl <- tbl(src_cmp, "ms_compound")

## Extract the id, name and inchi
cmp_tbl \%>\% select(compound_id, name, inchi) \%>\% collect()
}
\seealso{
\code{\link[=createCompDb]{createCompDb()}} for the function to create a SQLite compound database.

\code{\link[=CompoundIdFilter]{CompoundIdFilter()}} for filters that can be used on the \code{CompDb} database.
}
\author{
Johannes Rainer
}
