document.addEventListener('turbolinks:load', () => {

    // ページが読み込まれるたびに条件をチェック
  if (/^\/users\//.test(window.location.pathname)) {
    const userAvatarInput = document.getElementById('user_avatar');
    
    // 既存のアイコン画像のURLを取得（Rubyのビューで設定）
    const existingAvatarUrl = document.querySelector('#user_avatar').dataset.existingAvatar;
  
    // 既存の画像があればプレビューを設定
    if (existingAvatarUrl) {
      let imgPreview = document.getElementById('avatar-preview');
      if (!imgPreview) {
        imgPreview = document.createElement('img');
        imgPreview.id = 'avatar-preview';
        userAvatarInput.parentNode.insertBefore(imgPreview, userAvatarInput.nextSibling);
      }
      imgPreview.src = existingAvatarUrl;
    }
    
    userAvatarInput.addEventListener('change', (event) => {
  
      const file = event.target.files[0];
      const reader = new FileReader();
  
      reader.onload = (readEvent) => {
        let imgPreview = document.getElementById('avatar-preview');
        if (!imgPreview) {
          imgPreview = document.createElement('img');
          imgPreview.id = 'avatar-preview';
          userAvatarInput.parentNode.insertBefore(imgPreview, userAvatarInput.nextSibling);
        }
        imgPreview.src = readEvent.target.result;
      };
  
      reader.readAsDataURL(file);
    });
  }
});
