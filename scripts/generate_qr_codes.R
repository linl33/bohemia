library(bohemia)
ids <- sample(1000000:9999999, 100)
bohemia::render_qr_pdf(ids = ids,
                       output_dir = '~/Desktop',
                       output_file = 'qrs.pdf')