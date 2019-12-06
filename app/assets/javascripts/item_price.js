document.addEventListener('turbolinks:load', function () {

  if (!$('#selected-item-images')[0]) return false; //カテゴリのフォームがないなら以降実行しない。

  const min_price = 300; // 最低価格

  function changeFeeAndProfit() { // 価格から販売手数料、販売利益を算出して反映させる。
    $("#fee").text("-");
    $("#profit").text("-");
    if ($("#item_price").val().match(/\./)) return false; // .が含まれている＝整数ではないので終了。
    if (isNaN($("#item_price").val())) return false; // 数値ではないなら終了。
    let price = Number($("#item_price").val());
    if (Number(price) < min_price) return false; // 最低価格未満なら終了。
    let fee = Math.floor(price * 0.1); // Math.floorで小数を切り捨てる。
    $("#fee").text(`¥${fee}`);
    $("#profit").text(`¥${price-fee}`);
  }

  changeFeeAndProfit(); // ブラウザの戻るボタン対策

  $("#item_price").on("input", function () { //価格が変更されたら販売手数料、販売利益に反映させる。
    changeFeeAndProfit();
  })

});
