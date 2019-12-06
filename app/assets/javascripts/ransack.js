$(function () {

  if (!$('.search-form')[0]) return false; //詳細検索ページではないなら以降実行しない。

  $('.search-form').on('change', '.search-checkboxes input', function () { //「すべて」にチェックを入れた時全てのチェックボックスにチェックを入れる
    if ($(this).val() != -1) { // 値が-1では無いとき＝すべてでは無い
      $(this).siblings('input[value="-1"]').prop("checked", false); // 「すべて」のチェックを外しておく
      return false // 終了
    }
    var check = true;
    if ($(this).prop("checked") == false) check = false; // 「すべて」に既にチェックが入っている時、逆にチェックを外す
    $(this).siblings('input[type="checkbox"]').prop("checked", check); // 全チェックボックスを操作する
  });
  /////////「すべて」にチェックを入れた時全てのチェックボックスにチェックを入れる/////////

  $('#q_price').on('change', function () { //priceのプルダウンメニューを選択した時
    values = $(this).val().split(','); // valには「"300,1000"」といった文字列が入っているので「,」で区切って配列化する
    $('#q_price_gteq').val(values[0]) // 最低価格にvalues[0]を設定
    $('#q_price_lteq').val(values[1]) // 最高価格にvalues[1]を設定
  });
  /////////priceのプルダウンメニューを選択した時ここまで/////////

  $('.search-form__buttons--clear').on('click', function () { // クリアボタンを押した時（検索条件のリセット）
    $('input[type="checkbox"]').prop("checked", false);
    $('select, input[type="search"], input[type="text"]').val("");
    $('select[id="q_s_0_name"]').val("created_at DESC");
    $('.search-form-added').remove();
  });
  /////////クリアボタンを押した時（検索条件のリセット）ここまで/////////

});
