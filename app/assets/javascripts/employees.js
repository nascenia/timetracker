function validateFiles(inputFile) {
    var maxExceededMessage = "This file exceeds the maximum allowed file size (50 MB)";
    var extErrorMessage = "Only file with extension: .pdf is allowed";
    var allowedExtension = ["pdf"];

    var extName;
    var maxFileSize = $(inputFile).data('max-file-size');
    var sizeExceeded = false;
    var extError = false;

    $.each(inputFile.files, function() {
        if (this.size && maxFileSize && this.size > parseInt(maxFileSize)) {sizeExceeded=true;};
        extName = this.name.split('.').pop();
        if ($.inArray(extName, allowedExtension) == -1) {extError=true;};
    });

    if (sizeExceeded) {
        window.alert(maxExceededMessage);
        $(inputFile).val('');
    };

    if (extError) {
        window.alert(extErrorMessage);
        $(inputFile).val('');
    };
}