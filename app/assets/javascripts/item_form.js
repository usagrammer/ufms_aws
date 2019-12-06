document.addEventListener('turbolinks:load', function () {

  if (!$('#selected-item-images')[0]) return false; //カテゴリのフォームがないなら以降実行しない。

  const item_images_limit = 5; //添付できる画像の枚数
  const form = $("form"); //form要素を変数に入れておく。

  function newItemImage(blob, index) { //選択した画像をappendする。
    html = `
            <div class="item-image new" data-index=${index}>
              <img src =${blob} class="item-image__image">
              <div class="item-image__buttons">
                <div class="item-image__buttons--edit">
                編集
                </div>
                <div class="item-image__buttons--delete">
                削除
                </div>
              </div>
            </div>
            `;
    $("#select-image-button").before(html);
  }
  /////////newItemImage()ここまで/////////

  function newUploadItemImageField() { //新規画像投稿用のfile_fieldを作成しappendする。
    let new_file_field_index = $(`.new-item-image`).last()[0].dataset.index
    // Numberメソッド→引数を数値に変換する
    // datasetメソッドで取得すると全て文字列になってしまうためこうする
    // dataメソッドならこれをやる必要はない
    new_file_field_index = Number(new_file_field_index) + 1;
    let html = `
                <input class="new-item-image" id="file_field_index_${new_file_field_index}" name="item[item_images_attributes][${new_file_field_index}][image]" accept="image/*" type="file" data-index="${new_file_field_index}">
              `
    $("#image-file-fields").append(html);
  }
  /////////newUploadItemImageField()ここまで/////////

  function newChangeItemImageField() { //画像変更用のfile_fieldを作成しappendする。
    let html = `<input id="change-item-image" accept="image/*" data-index="" type="file" name="">` // 新しく画像変更用のfile_fieldを組み立てる。
    $("#image-file-fields").append(html); //新しい画像変更用のfile_fieldをappendする。
  }
  /////////newChangeItemImageField()ここまで/////////

  ///////////////////////////////////////////////////////////////
  /////////画像のindexを振り直す/////////
  ///////////////////////////////////////////////////////////////
  $('#selected-item-images').on('DOMSubtreeModified propertychange', function () { // #selected-item-images内に変化があった時発火する
    let uploaded_images_count = $(`input[type="checkbox"]`).length;
    let new_file_fields = $(`.item-image.new`); // 新規画像用のfile_fieldを取得する。
    for (i = 0; i < new_file_fields.length; i++) {
      let before_index = $(new_file_fields[i])[0].dataset.index;
      let new_index = i + uploaded_images_count;
      if ($(`.item-image[data-index=${before_index}]`)[0]) $(`.item-image[data-index=${before_index}]`)[0].dataset.index = new_index;
      $(`#file_field_index_${before_index}`)[0].dataset.index = new_index;
      $(`#file_field_index_${before_index}`).attr("name", `item[item_images_attributes][${new_index}][image]`);
      $(`#file_field_index_${before_index}`).attr("id", `file_field_index_${new_index}`);
    }
  });
  /////////画像のindexを振り直す/////////

  ///////////////////////////////////////////////////////////////
  /////////画像の投稿ボタン（グレーのブロック）をクリックした時。/////////
  ///////////////////////////////////////////////////////////////
  $("#select-image-button").on("click", function () {
    if ($(".item-image__image").length >= item_images_limit) { //プレビュー画像のlength＝UPされた画像の枚数。画像枚数の上限に引っかかる場合はここで終了。
      alert.log("これ以上画像UPできません ");
      return false;
    }
    let file_field = $(`.new-item-image`).last(); // 新規画像投稿用の最後のfile_fieldを取得する。
    file_field.trigger("click"); // file_fieldをクリックさせる。
  });
  /////////画像の投稿ボタン（グレーのブロック）をクリックした時ここまで/////////

  /////////////////////////////////////////////
  /////////画像の削除ボタンをクリックした時/////////
  ////////////////////////////////////////////
  $("#selected-item-images").on("click", ".item-image__buttons--delete", function (e) {
    e.stopPropagation(); // 親要素のイベントが発火するのを防ぐ。
    let image_wrapper = $(this).parents(".item-image"); // 削除する画像の大枠を取得する。
    let index = image_wrapper[0].dataset.index; //何番目の画像を削除するか選択する。
    image_wrapper.remove() // プレビュー画像を削除する。
    $(`#item_item_images_attributes_${index}__destroy`).prop("checked", true); //削除予定か否かのチェックをいれておく。
    $(`#file_field_index_${index}`).remove();
  });
  /////////画像の削除ボタンをクリックした時ここまで/////////

  /////////////////////////////////////////////
  /////////画像の編集ボタンをクリックした時/////////
  ////////////////////////////////////////////
  $("#selected-item-images").on("click", ".item-image__buttons--edit", function (e) { // 画像の編集ボタンをクリックした時。
    e.stopPropagation(); // 親要素のイベントが発火するのを防ぐ。
    let index = $(this).parents(".item-image")[0].dataset.index; //何番目の画像を変更するか選択する。
    $("#change-item-image")[0].dataset.index = index; //画像変更用ののdata-indexを更新しておく。
    // ↑これは、$(`#image-file-fields`).on("change")が発火した際にどの画像を変更しようとしていたのか判定するため。
    $("#change-item-image").trigger("click"); // 画像変更用のfile_fieldをクリックさせる。
  });
  /////////画像の編集ボタンをクリックした時ここまで/////////

  /////////////////////////////////////////////
  /////////file_fieldが変化した時/////////
  ////////////////////////////////////////////
  $(`#image-file-fields`).on("change", `input[type="file"]`, function (e) { //新しく画像が選択された、もしくは変更しようとしたが何も選択しなかった時
    let file = e.target.files[0];
    let index = $(this)[0].dataset.index //何番目の画像か
    let blob = window.URL.createObjectURL(file); //選択された画像をblob形式に変換する。
    //↑このblobをsrc属性値として使ったimgタグを表示することで、投稿画像のプレビュー機能になる。
    if ($(this).attr("id") == "change-item-image") { // 画像変更の場合
      let image = $(`.item-image[data-index=${index}]`).children("img"); // 変更するプレビュー画像を取得する。
      image.attr('src', blob); // プレビュー画像のsrc属性を変更する。
      $(`#file_field_index_${index}`).after(this); //画像変更用のfile_fieldを変更前のfile_fieldの後ろへ移動する。
      $(`#file_field_index_${index}`).remove(); //変更前のfile_fieldを削除する。
      //画像変更用のfile_fieldのid,name,classを変更前のfile_fieldと同じようにする。↓ここからーーー
      $(this).attr("id", `id="file_field_index_${index}"`);
      $(this).attr("name", `item[item_images_attributes][${index}][image]`);
      $(this).attr("class", `new-item-image`);
      //画像変更用のfile_fieldのid,name,classを変更前のfile_fieldと同じようにする。↑ここまでーーー
      $(`#item_item_images_attributes_${index}__destroy`).prop("checked", false); //削除予定か否かのチェックを外しておく。
      newChangeItemImageField(); // 新しく画像変更用のfile_fieldを組み立ててappendする。
      return false
    }
    newItemImage(blob, index); // 選択された画像のプレビューを表示する。
    newUploadItemImageField(); //新規画像投稿用のfile_fieldを組み立ててappendする。
  });
  /////////file_fieldが変化した時ここまで/////////

  /////////////////////////////////////////////
  /////////出品ボタンをクリックした時/////////
  ////////////////////////////////////////////
  $(`input[type="submit"]`).on("click", function (e) { // formをsubmitではなく、送信ボタンをclickにしておく
    e.preventDefault();

    let url = "/api" + form.attr("action");
    let formData = new FormData(form[0]);

    $.ajax({
        url: url,
        type: 'POST',
        data: formData,
        dataType: 'json',
        processData: false,
        contentType: false
      })
      .done(function (item) {
        if (item.error_messages) { // @error_messagesがある場合、何かしらエラーが発生している
          // バリデーションエラーメッセージを表示していく
          $(`.error-field`).text(""); // バリデーションエラーメッセージをリセット
          Object.keys(item.error_messages).forEach(function (key) {
            // メッセージは2件以上入っている場合があるが先頭の1つだけを表示
            $(`.error-field[data-column-name="${key}"]`).text(item.error_messages[key][0]);
          });
          // アラートを表示して中断
          alert("商品出品に失敗しました");
          return false;
        }
        $("form").append(`<input type="hidden" value="true" name="completed">`)
        $("form").submit();
      })
      .fail(function () {
        alert("商品出品に失敗しました");
      })
      .always(function () {
        $(".button").prop('disabled', false);
      })

  })
  /////////出品ボタンを押した時ここまで/////////

});
