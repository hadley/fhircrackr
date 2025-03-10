% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flatten_resources.R
\docType{methods}
\name{fhir_crack}
\alias{fhir_crack}
\alias{fhir_crack,ANY,fhir_table_description-method}
\alias{fhir_crack,fhir_table_description-method}
\alias{fhir_crack,ANY,fhir_design-method}
\alias{fhir_crack,fhir_design-method}
\title{Flatten list of FHIR bundles}
\usage{
fhir_crack(
  bundles,
  design,
  sep = NULL,
  brackets = NULL,
  rm_empty_cols = NULL,
  verbose = 2,
  data.table = FALSE,
  format = NULL,
  keep_attr = NULL,
  ncores = 1,
  remove_empty_columns = deprecated()
)

\S4method{fhir_crack}{ANY,fhir_table_description}(
  bundles,
  design,
  sep = NULL,
  brackets = NULL,
  rm_empty_cols = NULL,
  verbose = 2,
  data.table = FALSE,
  format = NULL,
  keep_attr = NULL,
  ncores = 1,
  remove_empty_columns = deprecated()
)

\S4method{fhir_crack}{ANY,fhir_design}(
  bundles,
  design,
  sep = NULL,
  brackets = NULL,
  rm_empty_cols = NULL,
  verbose = 2,
  data.table = FALSE,
  format = NULL,
  keep_attr = NULL,
  ncores = 1,
  remove_empty_columns = deprecated()
)
}
\arguments{
\item{bundles}{A FHIR search result as returned by \code{\link[=fhir_search]{fhir_search()}}.}

\item{design}{A \linkS4class{fhir_design} or \linkS4class{fhir_table_description} object. See \code{\link[=fhir_design]{fhir_design()}}/\code{\link[=fhir_table_description]{fhir_table_description()}}
and the corresponding vignette (\code{vignette("flattenResources", package ="fhircrackr")}) for a more detailed explanation and
comprehensive examples of both.}

\item{sep}{Optional. A character of length one containing the separator string used for separating multiple entries in cells when \code{format = "compact"}.
Will overwrite the \code{sep} defined in \code{design}. If \code{sep = NULL}, it is looked up in \code{design}, where the default is \code{":::"}.}

\item{brackets}{Optional. A character of length one or two used for the indices of multiple entries, which will overwrite the \code{brackets} defined in \code{design}.
If \code{brackets = NULL}, it is looked up in \code{design}, where the default is \code{character(0)},i.e. no indices are added to multiple entries.
Empty strings (\code{""}) are not allowed.}

\item{rm_empty_cols}{Optional. Remove empty columns? Logical scalar which will overwrite the \code{rm_empty_cols} defined in
\code{design}. If \code{rm_empty_cols = NULL}, it is looked up in \code{design}, where the default is \code{FALSE}.}

\item{verbose}{An integer vector of length one. If 0, nothing is printed, if 1, only finishing message is printed, if > 1,
extraction progress will be printed. Defaults to 2.}

\item{data.table}{A logical vector of length one. If it is set to TRUE the fhir_crack-function returns a data.table, otherwise a data.frame.
Defaults to FALSE.}

\item{format}{Optional. A character of length one indicating whether the resulting table should be cracked to a \code{wide} or \code{compact} format. Will overwrite the \code{format} defined
in \code{design} which defaults to \code{compact}. \code{wide} means multiple entries will be distributed over several columns with indexed names. \code{compact} means multiple entries will be pasted into one cell/column separated by \code{sep}.}

\item{keep_attr}{Optional. A logical of length one indicating whether the attribute name of the respective element (\verb{@value} in most cases)
should be attached to the name of the variable in the resulting table. Will overwrite \code{keep_attr} in \code{design} which defaults to \code{FALSE}.}

\item{ncores}{Either NULL (no parallelisation) or an integer of length 1 containing the number of
cpu cores that should be used for parallelised cracking. Defaults to NULL.}

\item{remove_empty_columns}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}} Use argument \code{rm_empty_cols} instead.}
}
\value{
If a \linkS4class{fhir_design} was used, the result is a list of data.frames, i.e. a \linkS4class{fhir_df_list} object, or a list of data.tables,
i.e. a \linkS4class{fhir_dt_list} object. If a \linkS4class{fhir_table_description} was used, the result is a single data.frame/data.table.
}
\description{
Converts a \linkS4class{fhir_bundle_list} (the result of \code{\link[=fhir_search]{fhir_search()}} to a list of data.frames/data.tables,
i.e. a \linkS4class{fhir_df_list}/\linkS4class{fhir_dt_list} if a \linkS4class{fhir_design} is given in the argument \code{design}.
Creates a single data.frame/data.table, if only a \linkS4class{fhir_table_description} is given in the argument \code{design}.

There are two main output formats for the table: compact and wide. They differ regarding their handling of multiple entries for
the same FHIR element (e.g. \code{Patient.adress}). In the compact format multiple entries are pasted together into one cell/column,
in the wide format multiple entries are distributed over several (indexed) columns. If none of the resources contains any multiple
values on the extracted elements, the two formats will result in the same basic structure.

To increase speed with larger amounts of data the cracking process can be parallelised over a number of cores defined in the
\code{ncores} argument.
}
\examples{
#unserialize example bundle
bundles <- fhir_unserialize(medication_bundles)


###Example 1###
#Extract just one resource type

#define attributes to extract
medications <- fhir_table_description(
   resource = "MedicationStatement",
   cols     = c(
   	MS.ID              = "id",
   	STATUS.TEXT        = "text/status",
   	STATUS             = "status",
   	MEDICATION.SYSTEM  = "medicationCodeableConcept/coding/system",
   	MEDICATION.CODE    = "medicationCodeableConcept/coding/code",
   	MEDICATION.DISPLAY = "medicationCodeableConcept/coding/display",
   	DOSAGE             = "dosage/text",
    	PATIENT            = "subject/reference",
    	LAST.UPDATE        = "meta/lastUpdated"
  ),
  sep           = " ",
  brackets      = c("[", "]"),
  rm_empty_cols = FALSE
)

med_df <- fhir_crack(bundles = bundles, design = medications)

head(med_df) #data.frame


###Example 2###
#extract more resource types

patients <- fhir_table_description(
   resource = "Patient"
)

design <- fhir_design(medications, patients)

df_list <- fhir_crack(bundles = bundles, design = design)

#list of data.frames/fhir_df_list
head(df_list$medications)
head(df_list$patients)

#The design that was used can be extracted from a fhir_df_list
fhir_design(df_list)

}
\seealso{
\itemize{
\item Downloading bundles from a FHIR server: \code{\link[=fhir_search]{fhir_search()}}
\item Creating designs/table_descriptions: \code{\link[=fhir_table_description]{fhir_table_description()}} and \code{\link[=fhir_design]{fhir_design()}}
\item Dealing with multiple entries: \code{\link[=fhir_melt]{fhir_melt()}}, \code{\link[=fhir_cast]{fhir_cast()}}, \code{\link[=fhir_rm_indices]{fhir_rm_indices()}}
}
}
