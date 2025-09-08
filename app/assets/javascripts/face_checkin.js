$(document).ready(function() {
  var video = document.getElementById('face-video');
  var stream = null;
  var canvas = document.createElement('canvas');
  var ctx = canvas.getContext('2d');
  var FRAME_COUNT = 3;
  var CAPTURE_INTERVAL = 100;
  var COUNTDOWN_SECONDS = 2;
  var frames = [];
  var deviceType = /Mobi|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ? 'mb' : 'pc';

  function showStatus(msg, type) {
    if (type === undefined) { type = 'info'; }
    $('#auto-face-status-message').removeClass().addClass('alert alert-' + type).text(msg).show();
  }
  function hideStatus() {
    $('#auto-face-status-message').hide();
  }
  function resetModal() {
    $('.video-container').show();
    $('.canvas-container').hide();
    $('#face-start-camera-btn').show();
    hideStatus();
    if (video && video.srcObject) video.play();
  }
  function startCamera() {
    // Always re-acquire the current video element in case DOM was replaced (e.g., Turbolinks)
    video = document.getElementById('face-video');
    if (stream) {
      if (video) {
        video.srcObject = stream;
        return video.play().catch(function() {});
      }
      return Promise.resolve();
    }
    return navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user', width: { ideal: 640 }, height: { ideal: 480 } } }).then(function(mediaStream) {
      stream = mediaStream;
      if (video) {
        video.srcObject = stream;
        return video.play();
      }
    });
  }
  function setCanvasSize() {
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
  }
  function countdown(seconds) {
    var i = seconds;
    function next() {
      if (i > 0) {
        showStatus('Get ready! Liveness check will start in ' + i + '...', 'info');
        i--;
        return new Promise(function(res) { setTimeout(function() { res(next()); }, 1000); });
      } else {
        return Promise.resolve();
      }
    }
    return next();
  }
  function captureFrames() {
    frames = [];
    setCanvasSize();
    var i = 0;
    function captureNext() {
      if (i < FRAME_COUNT) {
        ctx.save();
        ctx.translate(canvas.width, 0);
        ctx.scale(-1, 1); // Non-mirrored
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
        ctx.restore();
        return new Promise(function(resolve) {
          canvas.toBlob(function(blob) {
            frames.push(blob);
            showStatus('Capturing liveness video... (' + (i+1) + '/' + FRAME_COUNT + ')', 'info');
            i++;
            setTimeout(function() { resolve(captureNext()); }, CAPTURE_INTERVAL);
          }, 'image/jpeg', 0.8);
        });
      } else {
        return Promise.resolve();
      }
    }
    return captureNext();
  }
  function runLivenessAndRecognitionUnified() {
    startCamera()
      .then(function() {
        showStatus('Position your face in the center. Ensure good lighting.', 'info');
        return new Promise(function(res) { setTimeout(res, 1000); });
      })
      .then(function() { return countdown(COUNTDOWN_SECONDS); })
      .then(function() { return captureFrames(); })
      .then(function() {
        showStatus('Checking liveness and recognizing face...', 'info');
        var formData = new FormData();
        frames.forEach(function(frame, idx) { formData.append('frames[]', frame, 'frame' + idx + '.jpg'); });
        formData.append('device_type', deviceType);
        return fetch('/api/face/liveness_and_recognition', { method: 'POST', body: formData });
      })
      .then(function(response) { return response.json(); })
      .then(function(result) {
        if (result.success && result.user_id) {
          showStatus('✅ Liveness check passed and face recognized!' + (result.user_name ? (' For ' + result.user_name) : ''), 'success');
          setTimeout(function() {
            if (typeof window.onFaceCheckinSuccess === 'function') {
              window.onFaceCheckinSuccess();
            } else {
              window.location.href = '/';
            }
          }, 500);
        } else {
          showStatus('❌ ' + (result.error || 'Liveness or recognition failed.'), 'danger');
          setTimeout(function() { restartProcess(); }, 2500);
        }
      })
      .catch(function(e) {
        var errorMessage = 'An unexpected error occurred.';
        if (e.name === 'NotAllowedError' || e.name === 'PermissionDeniedError') {
          errorMessage = 'Camera access was denied. Please enable camera permissions in your browser settings.';
        } else if (e.name === 'NotFoundError' || e.name === 'DevicesNotFoundError') {
          errorMessage = 'No camera was found on your device.';
        } else if (e.message) {
          errorMessage = e.message;
        }
        showStatus('❌ Error: ' + errorMessage, 'danger');
        setTimeout(function() { restartProcess(); }, 3000);
      });
  }
  function restartProcess() {
    if (stream) {
      stream.getTracks().forEach(function(track) { track.stop(); });
      stream = null;
    }
    frames = [];
    hideStatus();
    $('#face-start-camera-btn').show();
    $('.video-container').show();
    $('.canvas-container').hide();
    if (video) {
      try { video.pause(); } catch (e) {}
      try { video.srcObject = null; } catch (e) {}
    }
  }
  // Use delegated handler to survive DOM replacements
  $(document).on('click', '#face-start-camera-btn', function() {
    $('#face-start-camera-btn').hide();
    runLivenessAndRecognitionUnified();
  });
  // Ensure fresh references and UI every time the modal opens
  $('#faceCheckInModal').on('shown.bs.modal', function() {
    // Re-grab DOM elements after potential partial page updates
    video = document.getElementById('face-video');
    resetModal();
  });

  $('#faceCheckInModal').on('hidden.bs.modal', function() {
    if (stream) {
      stream.getTracks().forEach(function(track) { track.stop(); });
      stream = null;
    }
    frames = [];
    hideStatus();
    $('#face-start-camera-btn').show();
    $('.video-container').show();
    $('.canvas-container').hide();
    if (video) {
      try { video.pause(); } catch (e) {}
      try { video.srcObject = null; } catch (e) {}
    }
  });
  $('#face-checkin-btn').click(function() {
    $('#faceCheckInModal').modal('show');
  });
  // Show glasses instruction for PC only
  if (deviceType === 'pc') {
    $('#face-glasses-instruction').show();
  }
});
