$AppList = @(
    'Microsoft.EdgeWebView2Runtime',
    'M2Team.NanaZip',
    'Google.Chrome',
    'Mozilla.Firefox',
    # 'PDFgear.PDFgear',
    # 'TheDocumentFoundation.LibreOffice',
    'VideoLAN.VLC',
    'CodecGuide.K-LiteCodecPack.Mega',
    'Notepad++.Notepad++'
)

foreach ($App in $AppList) {

    $Args = @(
        'install',
        '--scope=machine',
        '--accept-source-agreements',
        '--accept-package-agreements',
        '--force',
        '--silent',
        '-e',
        '--id',
        $App
    )

    & winget $Args
}
