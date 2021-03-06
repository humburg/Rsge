
                                        # $Id: sge.parRapply.R,v 1.2 2006/12/15 15:21:23 kuhna03 Exp $

sge.apply <- function(X, MARGIN, FUN, ..., 
                          join.method=cbind,
                          njobs,
                          batch.size=getOption('sge.block.size'),
                          packages=NULL,
                          sources=NULL,
                          global.savelist=NULL,
                          function.savelist=NULL,
                          cluster=getOption('sge.use.cluster'),
                          trace=getOption('sge.trace'),
                          debug=getOption('sge.debug'),
                          file.prefix=getOption('sge.file.prefix')
                         ) {
    if(MARGIN == 1) {
      sge.parRapply(X, FUN, ...,
                   join.method=join.method,cluster=cluster,
                   njobs=njobs, batch.size=batch.size,
                   packages=packages, sources=sources,
                   global.savelist=global.savelist, 
                   function.savelist=function.savelist,
                   trace=trace, debug=debug, file.prefix=file.prefix)
    } else {
      sge.parCapply(X, FUN, ...,
                   join.method=join.method,cluster=cluster,
                   njobs=njobs, batch.size=batch.size,
                   packages=packages, sources=sources,
                   global.savelist=global.savelist, 
                   function.savelist=function.savelist,
                   trace=trace, debug=debug, file.prefix=file.prefix)
    } 
} 

sge.parCapply <- function(X, FUN, ..., 
                          join.method=cbind,
                          njobs,
                          batch.size=getOption('sge.block.size'),
                          packages=NULL,
                          sources=NULL,
                          global.savelist=NULL,
                          function.savelist=NULL,
                          cluster=getOption('sge.use.cluster'),
                          trace=getOption('sge.trace'),
                          debug=getOption('sge.debug'),
                          file.prefix=getOption('sge.file.prefix')
                         ) {
  if(cluster) {
    sge.parParApply(t(X), FUN, ..., 
               join.method=join.method,  
               njobs=njobs, batch.size=batch.size,
               packages=packages, sources=sources,
               global.savelist=global.savelist, 
               function.savelist=function.savelist,
               trace=trace, debug=debug, file.prefix=file.prefix, apply.method=2
               )
  } else {
    if(trace) cat("Running locally \n")
    apply(X=X, MARGIN=2 ,FUN=FUN, ...)
  }
 
}

sge.parRapply <- function(X, FUN, ...,
                          join.method=cbind,
                          njobs, 
                          batch.size=getOption('sge.block.size'),
                          packages=NULL,
                          sources=NULL,
                          global.savelist=NULL,
                          function.savelist=NULL,
                          cluster=getOption('sge.use.cluster'),
                          trace=getOption('sge.trace'),
                          debug=getOption('sge.debug'),
                          file.prefix=getOption('sge.file.prefix')
                         ) {
  if(cluster) {
    sge.parParApply(X, FUN, ...,  
                join.method=join.method, 
                njobs=njobs, batch.size=batch.size,
                packages=packages, sources=sources,
                global.savelist=global.savelist, 
                function.savelist=function.savelist,
                trace=trace, debug=debug, file.prefix=file.prefix, apply.method=2
                )
  } else {
    if(trace) cat("Running locally \n")
    apply(X=X, MARGIN=1 ,FUN=FUN, ...)
  }
}

sge.parLapply <- function(X, FUN, ..., 
                          join.method=c, 
                          njobs,
                          batch.size=getOption('sge.block.size'),
                          packages=NULL,
                          sources=NULL,
                          global.savelist=NULL,
                          function.savelist=NULL,
                          cluster=getOption('sge.use.cluster'),
                          trace=getOption('sge.trace'),
                          debug=getOption('sge.debug'),
                          file.prefix=getOption('sge.file.prefix')
                          ) {
  if(cluster) {
    sge.parParApply(X, FUN, ...,
                join.method=join.method, njobs=njobs, 
                batch.size=batch.size,
                packages=packages, sources=sources,
                global.savelist=global.savelist,
                function.savelist=function.savelist,
                trace=trace, debug=debug, file.prefix=file.prefix, apply.method=1
                )
  } else {
    if(trace) cat("Running locally\n")
    lapply(X=X, FUN=FUN, ...)
  }
}

# this code was blatently taken from snow, whose code was taken from sapply.R

sge.parSapply <- function(X, FUN, ..., 
                          USE.NAMES=TRUE, simplify=TRUE,
                          join.method=c, 
                          njobs,
                          batch.size=getOption('sge.block.size'),
                          packages=NULL,
                          sources=NULL,
                          global.savelist=NULL,
                          function.savelist=NULL,
                          cluster=getOption('sge.use.cluster'),
                          trace=getOption('sge.trace'),
                          debug=getOption('sge.debug'),
                          file.prefix=getOption('sge.file.prefix')
                         )
{
  
  if(cluster) {
    FUN <- match.fun(FUN) # should this be done on slave?
    answer <- sge.parParApply(X, FUN, ...,
               join.method=join.method, njobs=njobs, 
               batch.size=batch.size,
               packages=packages, sources=sources,
               global.savelist=global.savelist, 
               function.savelist=function.savelist,
               trace=trace, debug=debug, 
               file.prefix=file.prefix, apply.method=1
              )
#    answer <- sge.parLapply(as.list(x), fun, ...)
      if (USE.NAMES && is.character(X) && is.null(names(answer)))
        names(answer) <- X
      if (simplify && length(answer) != 0) {
        common.len <- unique(unlist(lapply(answer, length)))
        if (common.len == 1)
            unlist(answer, recursive = FALSE)
        else if (common.len > 1)
            array(unlist(answer, recursive = FALSE),
                  dim = c(common.len, length(X)),
                  dimnames = list(names(answer[[1]]), names(answer)))
        else answer
      }
      else answer
  } else {
    if(trace) cat("Running locally\n")
    sapply(X=X, FUN=FUN, ..., simplify=simplify, USE.NAMES=USE.NAMES)
  } 
}

sge.parParApply <- function (X, FUN, ...,
                           join.method=cbind,
                           njobs,
                           batch.size=getOption('sge.block.size'),
                           trace=getOption('sge.trace'),
                           packages=NULL,
                           sources=NULL,
                           global.savelist=NULL,
                           function.savelist=NULL,
                           debug=getOption('sge.debug'),
                           file.prefix=getOption('sge.file.prefix'),
                           apply.method=2

                         )
  {
    files.to.remove <- character()
    if (as.logical(getOption("sge.remove.files")))
      on.exit(lapply(files.to.remove, file.remove))
    # split X
    if(missing(njobs) && (is.matrix(X) || is.data.frame(X)))
      njobs <- max(1,ceiling(nrow(X)/batch.size))    
    else if(missing(njobs) && (is.vector(X) || is.list(X)))
      njobs <- max(1,ceiling(length(X)/batch.size))    

    if(debug) print(X)
    if(njobs>1)
      rowSet <- sge.split(X, njobs)
    else
      rowSet <- list(X)
    if(debug) print(rowSet)
    tmp.dir <- sge.save.dir()
    prefix <- tempfile(pattern = file.prefix, tmpdir = tmp.dir)
    filenames <- character(length(rowSet))
   # save the GLOBAL data
   if(apply.method == 1) {
        global.filename <- sge.globalPrep(
                          lapply, X=NULL, FUN=FUN, ...,
                          global.savelist=global.savelist,
                          function.savelist=function.savelist,
                          sge.packages=packages,sge.sources=sources,
                          debug=debug,prefix=prefix
                         )
   } else if(apply.method ==2) {
        global.filename <- sge.globalPrep(
                          apply, X=NULL, MARGIN=1, FUN=FUN, ...,
                          global.savelist=global.savelist,
                          function.savelist=function.savelist,
                          sge.packages=packages,sge.sources=sources,
                          debug=debug,prefix=prefix
                         )
   }
   files.to.remove <- c(files.to.remove, global.filename)
   #save X into the task specific file
   for (i in 1:length(rowSet)) {
      fnames <- sge.taskPrep(X=rowSet[[i]],index=i,prefix=prefix)
      filenames[i] <- fnames["ret.fname"]
      files.to.remove <- c(files.to.remove, fnames)
    } 
    if(trace) cat("Completed storing environment to disk\n")
    if(trace) cat("Submitting ",length(rowSet), "jobs...\n")
    if(debug) print(filenames)
    qsub          <- getOption("sge.qsub")
    qsub.options  <- getOption("sge.qsub.options")
    # put outputs in save directory
    qsub.options <- paste(qsub.options, "-e",tmp.dir,"-o",tmp.dir)
    qsub.user.opt <- getOption("sge.user.options")
    qsub.blocking <- getOption("sge.qsub.blocking")
    qsub.script   <- getOption("sge.script")
    script <- paste(file.path(path.package("Rsge"), qsub.script), prefix)
    result <- sge.system.tee(paste(qsub, " ",qsub.user.opt, " ", qsub.options, " ", qsub.blocking,  length(rowSet), " ", script, " 2>&1", sep=""),out=trace)
    if(sge.checkNotNow(result)) {
      cat("now option set, could not run now on cluster, running local.\n")
      if(apply.method == 1) {
        return(lapply(X=X, FUN=FUN, ...))
      } else {
        return(apply(X=X, MARGIN=1, FUN=FUN, ...))
      }
    }
    if(debug) cat( result, "\n")
    if(trace) cat("All jobs completed\n") 
    jobid <- sge.get.jobid(result)
    # mark all outputs for removal
    output.prefix <- file.path(tmp.dir,qsub.script)
    for (i in 1:length(rowSet))
      files.to.remove <-
        c(files.to.remove,
          paste(output.prefix,".",c("e","o"),jobid,".",i,sep=""))
    # show all error outputs, omitting library loading
    for (i in 1:length(rowSet)) {
      lines <- readLines(paste(output.prefix,".e",jobid,".",i,sep=""))
      package.load.lines <- grep("^Loading required package: ", lines)
      if (length(package.load.lines)>0)
        lines <- lines[-package.load.lines]
      if (length(lines)>0)
        cat(lines,sep="\n")
    }
    results <- lapply( filenames, sge.get.result, jobid = jobid)
    if(debug) print (results)
    # When c is run the try-errors are converted into strings
    # so its probably better to not combine errors, I
    # still need to seperately test this for cbind and consider other operations
    if(any(lapply(results , function(e1) class(e1) == "try-error") == TRUE)) {
      print("Not running join method since there are errors")
      results
    } else {
      retval <- do.call(join.method, results, quote=TRUE)
      retval
    }
  }
