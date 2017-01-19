library('shiny')
library('protr')

# dark actionButton
nx.actionButton = function (inputId, label, icon = NULL) {
  if (!is.null(icon))
    buttonContent <- list(icon, label)
  else buttonContent <- label
  tags$button(id = inputId, type = 'button', class = 'btn btn-primary action-button',
              buttonContent)
}

shinyUI(fluidPage(theme = 'cerulean.css',

                  fluidRow(column(12, includeHTML('header.html'))),

                  headerPanel(title = 'ProtrWeb', windowTitle = 'ProtrWeb'),

                  sidebarPanel(

                    radioButtons('formatType', 'Step 1. Choose file format',
                                 c('FASTA' = 'fasta',
                                   'Raw sequence' = 'rawseq')),

                    radioButtons('inputType', 'Step 2. Upload or paste?',
                                 c('Upload file' = 'uploadfile',
                                   'Paste file content' = 'pastecontent')),

                    strong('Step 3. Upload or paste protein sequence'),

                    conditionalPanel(
                      a('Click here to download an example FASTA file', href='example.fasta'),
                      br(),
                      condition = "input.formatType == 'fasta' & input.inputType == 'uploadfile'",
                      fileInput('file1', 'Upload FASTA file')
                    ),

                    conditionalPanel(
                      a('Click here to download an example FASTA file', href='example.fasta'),
                      br(),
                      condition = "input.formatType == 'fasta' & input.inputType == 'pastecontent'",
                      tags$textarea(id = 'text1', rows = 5, cols = 60, 'Paste FASTA file content here')
                    ),

                    conditionalPanel(
                      a('Click here to download an example raw sequence file', href='example.txt'),
                      br(),
                      condition = "input.formatType == 'rawseq' & input.inputType == 'uploadfile'",
                      fileInput('file2', 'Upload raw sequence file')
                    ),

                    conditionalPanel(
                      a('Click here to download an example raw sequence file', href='example.txt'),
                      br(),
                      condition = "input.formatType == 'rawseq' & input.inputType == 'pastecontent'",
                      tags$textarea(id = 'text2', rows = 5, cols = 60, 'Paste raw sequence here')
                    ),

                    tags$hr(),
                    strong('Step 4. Select descriptor type(s)'),
                    checkboxGroupInput('variable', 'Descriptor type (dimension):',
                                       c('Amino Acid Composition (20)' = 'aac',
                                         'Dipeptide Composition (400)' = 'dc',
                                         'Tripeptide Composition (8000)' = 'tc',
                                         'Normalized Moreau-Broto Autocorrelation (240)' = 'mb',
                                         'Moran Autocorrelation (240)' = 'moran',
                                         'Geary Autocorrelation (240)' = 'geary',
                                         'C/T/D (21 + 21 + 105)' = 'ctd',
                                         'Conjoint Triad (343)' = 'ctriad',
                                         'Sequence-Order-Coupling Number (60)' = 'socn',
                                         'Quasi-Sequence-Order Descriptors (100)' = 'qso',
                                         'Pseudo-Amino Acid Composition (50)' = 'paac',
                                         'Amphiphilic Pseudo-Amino Acid Composition (80)' = 'apaac')
                    ),

                    hr(),

                    nx.actionButton('protrsubmitButton', 'Compute selected descriptors', icon('check'))

                  ),

                  mainPanel(

                    tabsetPanel(id = 'protrwebmain',
                                tabPanel('Introduction',
                                         includeHTML('introtext.html')
                                ),

                                tabPanel('Computed Descriptors',
                                         h3('Computed Descriptors'),
                                         tags$hr(),
                                         tableOutput('desc'),
                                         tags$hr(),
                                         downloadButton('downloadData', 'Download as CSV',
                                                        class = 'btn btn-primary btn-large')
                                )

                    ),

                    includeHTML('footer.html')

                  )

))
