$(document).ready(function() {
  var video = document.getElementById('face-video');
  var stream = null;
  var canvas = document.createElement('canvas');
  var ctx = canvas.getContext('2d');
  var FRAME_COUNT = 5;
  var CAPTURE_INTERVAL = 100; // ms (5 frames in 1 second)
  var COUNTDOWN_SECONDS = 3;
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
    if (stream) return Promise.resolve();
    return navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' } }).then(function(mediaStream) {
      stream = mediaStream;
      video.srcObject = stream;
      video.play();
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
          }, 'image/jpeg', 1);
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
            window.location.href = '/';
          }, 500);
        } else {
          showStatus('❌ ' + (result.error || 'Liveness or recognition failed.'), 'danger');
          setTimeout(function() { restartProcess(); }, 2500);
        }
      })
      .catch(function(e) {
        showStatus('Error: ' + e, 'danger');
        setTimeout(function() { restartProcess(); }, 2500);
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
    if (video && video.srcObject) video.pause();
  }
  // Update button click handler to use the new function
  $('#face-start-camera-btn').click(function() {
    $('#face-start-camera-btn').hide();
    runLivenessAndRecognitionUnified();
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
    if (video && video.srcObject) video.pause();
  });
  $('#face-checkin-btn').click(function() {
    $('#faceCheckInModal').modal('show');
  });
  // Show glasses instruction for PC only
  if (deviceType === 'pc') {
    $('#face-glasses-instruction').show();
  }
});
