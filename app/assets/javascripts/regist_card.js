$(function () {

  if (!$('#regist_card')[0]) return false; //カード登録ページではないなら以降実行しない。

  Payjp.setPublicKey("pk_test_da1bbf6d51f1cb9771cfdc1d"); //公開鍵を読み込む。
  let regist_button = $("#regist_card"); //カード入力フォームの登録ボタン。

  regist_button.on("click", function (e) { //登録ボタンを押したとき（ここはsubmitではなくclickにしておく）。
    e.preventDefault();
    let now = new Date(); // exp_yearの算出用。
    // 各入力フォームを元にカード情報を作成する。
    let card = {
      number: $("#card_number_form").val(),
      cvc: $("#cvc_form").val(),
      exp_month: $("#exp_month_form").val(),
      exp_year: Number($("#exp_year_form").val()) + Math.round(now.getFullYear() / 100) * 100 //下②桁ではなく実際の年数を送る必要がある。
    };

    Payjp.createToken(card, (status, response) => { //cardをpayjpに送信して登録する。
      //status = HTTPステータス(404など), response = cardのtoken
      if (status === 200) { //成功した場合
        // formからname属性を削除することでparamsへ送られないようにする。
        // ※paramsにカード情報（番号など）を送ってはいけない！
        $("#card_number_form").removeAttr("name");
        $("#cvc_form").removeAttr("name");
        $("#exp_month_form").removeAttr("name");
        $("#exp_year_form").removeAttr("name");
        // ↓hidden_fieldにcardのtokenを入れることでtokenがparamsに送られる。
        $("#card_token").append(
          $('<input type="hidden" name="card_token">').val(response.id)
        );
        let form = $('#card_form')[0];
        // ↓formのsubmitボタンを強制起動する（ページが遷移してコントローラが起動する）。
        form.submit();
      } else {
        alert("カード情報が正しくありません。"); //確認用
        regist_button.prop('disabled', false);
      }

    }); //cardをpayjpに登録するここまで。

  }); //登録ボタンを押したときここまで。

});
