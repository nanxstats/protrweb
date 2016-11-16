library('shiny')
library('protr')

extractCTD = function (x) return(c(extractCTDC(x), extractCTDT(x), extractCTDD(x)))

shinyServer(function(input, output, session) {

  funcdict   = c(
    'aac'    = 'extractAAC',
    'dc'     = 'extractDC',
    'tc'     = 'extractTC',
    'mb'     = 'extractMoreauBroto',
    'moran'  = 'extractMoran',
    'geary'  = 'extractGeary',
    'ctd'    = 'extractCTD',
    'ctriad' = 'extractCTriad',
    'socn'   = 'extractSOCN',
    'qso'    = 'extractQSO',
    'paac'   = 'extractPAAC',
    'apaac'  = 'extractAPAAC')

  observe({
    # switch tab
    if ( (!is.null(input$file1) | !is.null(input$file2)) & !is.null(input$variable) & input$protrsubmitButton != 0L ) {
      updateTabsetPanel(session, "protrwebmain", selected = "Computed Descriptors")
    }
  })

  observe({
    # switch tab
    if ( ((input$text1 != 'Paste FASTA file content here') | (input$text2 != 'Paste raw sequence here')) & !is.null(input$variable) & input$protrsubmitButton != 0L ) {
      updateTabsetPanel(session, "protrwebmain", selected = "Computed Descriptors")
    }
  })

  # return computed descriptors
  descTable = reactive({

    fmtType = input$formatType
    iptType = input$inputType

    if ( fmtType == 'fasta' & iptType == 'uploadfile' & !is.null(input$file1) ) {
      seq = readFASTA(input$file1$datapath)
    }

    if ( fmtType == 'fasta' & iptType == 'pastecontent' & (input$text1 != 'Paste FASTA file content here') ) {
      seq = readFASTA(textConnection(input$text1))
    }

    if ( fmtType == 'rawseq' & iptType == 'uploadfile' & !is.null(input$file2) ) {
      seq = scan(input$file2$datapath, what = 'complex', blank.lines.skip = TRUE)
    }

    if ( fmtType == 'rawseq' & iptType == 'pastecontent' & (input$text2 != 'Paste raw sequence here') ) {
      seq = scan(textConnection(input$text2), what = 'complex', blank.lines.skip = TRUE)
    }

    if ( is.null(input$variable) ) {
      return(NULL)
    } else if ( length(as.character(input$variable)) >= 1L ) {

      exec = paste0('t(sapply(seq, ', funcdict[as.character(input$variable)], '))')
      outlist = vector('list', length(exec))

      withProgress(message = 'Computing...', value = 0, {

        n = length(exec)

        for ( i in 1L:n ) {
          outlist[[i]] = eval(parse(text = exec[i]))
          incProgress(1/n, detail = paste("Finished Part", i))
        }

      })

      out = do.call(cbind, outlist)
      return(out)

    } else {
      return(NULL)
    }

  })

  output$desc = renderTable({
    descT = descTable()
    descT
  })

  output$downloadData = downloadHandler(
    filename = function() { paste('ProtrWeb-', paste(input$variable, collapse = '-'),
                                  '-', gsub(' ', '-', gsub(':', '-', Sys.time())),
                                  '.csv', sep = '') },
    content = function(file) {
      csvTable = descTable()
      write.csv(csvTable, file)
    }
  )

})
