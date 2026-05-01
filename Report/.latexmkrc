# XeLaTeX engine
$pdf_mode = 5;

# Main TeX file
$root_filename = 'P2_T01.tex';

# Shell escape required for minted
set_tex_cmds("--shell-escape --synctex=1 --file-line-error %O %S");

# Biber for bibliography
$biber = "biber %O %S";
$bibtex_use = 1.5;

# Clean up extensions
$clean_ext = 'bbl blg brf idx ilg ind lof log lot out toc fdb_latexmk fls synctex.gz run.xml';

# Glossaries - Windows compatible
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    my ($base_name, $path) = fileparse($_[0]);
    pushd $path;
    if ($silent) {
        system "makeglossaries", "-q", $base_name;
    } else {
        system "makeglossaries", $base_name;
    };
    popd;
}
