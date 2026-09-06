$(document).on('click', '#register-face-btn', function() {
  // Only initialize once per modal open
  var initialized = false;
  var video, canvas, ctx, stream, userId, photoTaken, capturedPhoto, lastCaptureData;

  function showAutoFaceStatus(message, type) {
    $('#auto-face-status-message')
      .removeClass()
      .addClass('alert alert-' + type)
      .text(message)
      .show();
  }
  function hideAutoFaceStatus() {
    $('#auto-face-status-message').hide();
  }
  function showVideo() {
    $('.video-container').show();
    $('.canvas-container').hide();
    if (stream) {
      $('#capture-photo-btn').show();
    } else {
      $('#capture-photo-btn').hide();
    }
    $('#retake-photo-btn').hide();
    $('#start-over-btn').hide();
    $('#register-face-btn-modal').hide();
    photoTaken = false;
  }
  function showCanvas() {
    $('.video-container').hide();
    $('.canvas-container').show();
    $('#capture-photo-btn').hide();
    $('#retake-photo-btn').show();
    $('#start-over-btn').hide();
    $('#register-face-btn-modal').show();
    photoTaken = true;
  }

  function isMobileDevice() {
    return /Mobi|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  }

  function showGlassesInstruction() {
    if (!isMobileDevice()) {
      $('#glasses-instruction').show();
    } else {
      $('#glasses-instruction').hide();
    }
  }

  // Modal open event
  $('#faceRegistrationModal').one('shown.bs.modal', function() {
    if (initialized) return;
    initialized = true;
    video = document.getElementById('video');
    canvas = document.getElementById('canvas');
    ctx = canvas.getContext('2d');
    stream = null;
    userId = $('#register-face-btn').data('user-id') || null;
    photoTaken = false;
    capturedPhoto = null;
    faceLandmarker = null;
    lastCaptureData = null;
    showGlassesInstruction();
    hideAutoFaceStatus();
    showVideo();
    $('#start-camera-btn').show();
    $('#capture-photo-btn').hide();
    $('#start-over-btn').hide();
  });

  // Start camera
  $(document).off('click.faceRegStart').on('click.faceRegStart', '#start-camera-btn', function() {
    var constraints = { 
      video: { 
        width: { ideal: 640 },
        height: { ideal: 480 },
        facingMode: 'user'
      } 
    };

    function onStreamSuccess(mediaStream) {
      stream = mediaStream;
      video.srcObject = mediaStream;
      video.play();
      $('#start-camera-btn').hide();
      showVideo();
      hideAutoFaceStatus();
      $('#capture-photo-btn').show();
    }

    function onStreamError(err) {
      showAutoFaceStatus('Error accessing camera: ' + (err.message || 'Please check camera permissions in your browser.'), 'danger');
    }

    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      navigator.mediaDevices.getUserMedia(constraints)
        .then(onStreamSuccess)
        .catch(onStreamError);
    } else if (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia) {
      var legacyGetUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;
      legacyGetUserMedia.call(navigator, constraints, onStreamSuccess, onStreamError);
    } else if (location.protocol !== 'https:' && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
      showAutoFaceStatus('Camera access requires HTTPS. Please access Time Tracker using https:// instead of http://', 'danger');
    } else {
      showAutoFaceStatus('Camera not supported in this browser.', 'danger');
    }
  });

  // Capture photo
  $(document).off('click.faceRegCapture').on('click.faceRegCapture', '#capture-photo-btn', function() {
    var displayWidth = video.clientWidth;
    var displayHeight = video.clientHeight;
    var dpr = window.devicePixelRatio || 1;
    canvas.width = displayWidth * dpr;
    canvas.height = displayHeight * dpr;
    canvas.style.width = displayWidth + 'px';
    canvas.style.height = displayHeight + 'px';
    var videoRatio = video.videoWidth / video.videoHeight;
    var displayRatio = displayWidth / displayHeight;
    var sx, sy, sw, sh;
    if (videoRatio > displayRatio) {
        sw = video.videoHeight * displayRatio;
        sh = video.videoHeight;
        sx = (video.videoWidth - sw) / 2;
        sy = 0;
    } else {
        sw = video.videoWidth;
        sh = video.videoWidth / displayRatio;
        sx = 0;
        sy = (video.videoHeight - sh) / 2;
    }
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.save();
    ctx.translate(canvas.width, 0);
    ctx.scale(-1, 1);
    ctx.drawImage(
        video, 
        sx, sy, sw, sh,          // Source rectangle (cropped portion)
        0, 0, canvas.width, canvas.height  // Destination (full canvas)
    );
    ctx.restore();
    lastCaptureData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    // Save the image data for later
    var tempCanvas = document.createElement('canvas');
    tempCanvas.width = canvas.width;
    tempCanvas.height = canvas.height;
    tempCanvas.getContext('2d').putImageData(lastCaptureData, 0, 0);
    capturedPhoto = tempCanvas.toDataURL('image/jpeg', 1);
    showCanvas();
    hideAutoFaceStatus();
  });

  // Retake photo
  $(document).off('click.faceRegRetake').on('click.faceRegRetake', '#retake-photo-btn', function() {
    lastCaptureData = null;
    capturedPhoto = null;
    showVideo();
    hideAutoFaceStatus();
  });

  // Start over
  $(document).off('click.faceRegStartOver').on('click.faceRegStartOver', '#start-over-btn', function() {
    capturedPhoto = null;
    lastCaptureData = null;
    showVideo();
    hideAutoFaceStatus();
    $('#capture-photo-btn').hide();
    $('#start-over-btn').hide();
  });

  // Register face
  $(document).off('click.faceRegRegister').on('click.faceRegRegister', '#register-face-btn-modal', function() {
    if (!capturedPhoto) {
      showAutoFaceStatus('Please capture a photo first.', 'warning');
      return;
    }
    // Convert dataURL to blob
    function dataURLtoBlob(dataurl) {
      var arr = dataurl.split(','), mime = arr[0].match(/:(.*?);/)[1], bstr = atob(arr[1]), n = bstr.length, u8arr = new Uint8Array(n);
      while(n--){
        u8arr[n] = bstr.charCodeAt(n);
      }
      return new Blob([u8arr], {type:mime});
    }
    var photoBlob = dataURLtoBlob(capturedPhoto);
    var formData = new FormData();
    formData.append('image', photoBlob, 'capture.jpg');
    formData.append('user_id', userId);
    fetch('/api/face/register_face', {
      method: 'POST',
      body: formData
    })
    .then(function(response) { return response.json(); })
    .then(function(response) {
      if (response.success) {
        showAutoFaceStatus('Face registered successfully!', 'success');
        setTimeout(function() {
          $('#faceRegistrationModal').modal('hide');
          location.reload();
        }, 2000);
      } else {
        showAutoFaceStatus('Face registration failed: ' + response.error, 'danger');
      }
    })
    .catch(function(error) {
      showAutoFaceStatus('Error registering face: ' + error, 'danger');
    });
  });

  // Modal close event
  $('#faceRegistrationModal').on('hidden.bs.modal', function() {
    if (stream) {
      stream.getTracks().forEach(function(track) {
        track.stop();
      });
      stream = null;
    }
    $('#start-camera-btn').show();
    showVideo();
    capturedPhoto = null;
    lastCaptureData = null;
    hideAutoFaceStatus();
    $('#capture-photo-btn').hide();
    $('#start-over-btn').hide();
    initialized = false;
  });
});
