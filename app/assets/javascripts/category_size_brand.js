document.addEventListener('turbolinks:load', function () {

  if (!$('.select-category')[0]) return false; //カテゴリのフォームがないなら以降実行しない。

  var brand_names = []; // ブランドのインクリメンタルサーチ用
  var brand_groups = null; // brand_namesを更新する必要があるかどうかをチェックするのに使う
  var required_true = `required="required"`;
  if ($(".search-form")[0]) required_true = ""; // 詳細検索ページは諸々のフォームは入力必須ではなくなる

  // 孫カテゴリのフォームが存在しており尚且つvalueが空のとき（つまりバグっている時）
  // 強制的にリロードさせる
  if ($(`select[name="item[category_id]"]`).eq(2)[0] && !$(`select[name="item[category_id]"]`).eq(2).val()) {
    //戻るボタンを押したときカテゴリのselectがバグっている場合、リロードさせる。
    location.reload();
  }

  function buildCategoryForm(categories) { // カテゴリのフォームを組み立ててappendする。

    let options = `` // optionタグをひとまとめにする入れ物
    categories.forEach(function (category) { // カテゴリを一つずつ渡してoptionタグを一つずつ組み立てていく。
      options += buildOption(category);
    });

    let blank = "---"; // 一番上の選択肢の文字列
    let name = `name="item[category_id]"`;
    // $("#item_search")が存在する場合は詳細検索ページなのでname属性などを変更しておく
    if ($("#item_search")[0]) {
      name = "name=q[category_id_in][]";
      blank = "すべて";
    }

    let html = `
                <select ${required_true} class="select-category search-form-added" ${name}>
                <option value="">${blank}</option>
                  ${options}
                </select>
                `
    return html;
  }
  /////////buildCategoryForm()ここまで/////////

  function buildOption(category) { // 渡されてきたデータを使ってoptionタグを組み立てる。
    let option = `
                 <option value="${category.id}">${category.name}</option>
                 `
    return option;
  }
  /////////buildOption()ここまで/////////

  function buildCollectionForm(array, attribute) {
    let options = setCollectionOption(array, attribute);
    let html = `
    <div class= "search-checkboxes search-form-added">
      ${options}
    </select>
    </div>
    `
    return html;
  };
  /////////buildCollectionForm()ここまで/////////

  function setCollectionOption(options, attribute) {
    let option_list = ``;
    if (attribute != "category_id") { // 追加するフォームがカテゴリではなかったら先頭に「すべて」を追加する
      option_list += `
                        <input type="checkbox" value= "-1" name="q[${attribute}][]" id="q_${attribute}_in_all">
                        <label for="q_${attribute}_in_all">すべて</label>
                        `
    }
    $.each(options, function (i, option) {
      option_list += `
      <input type="checkbox" value= "${option.id}" name="q[${attribute}][]" id="q_${attribute}_${option.id}">
      <label for="q_${attribute}_${option.id}">${option.name}</label>
      `
    })
    return option_list;
  };
  /////////setCollectionOption()ここまで/////////

  $(document).on("change", "select.select-category", function () { //カテゴリが変更された時
    // ここでのthis = <select>省略</select>
    let category_id = $(this).val();
    if (!category_id) { // 「---」が選択されたら終了
      $(this).nextAll('.select-category').remove(); // 後続（変更されたのが親カテゴリなら子孫全て、子カテゴリなら孫カテゴリ、孫カテゴリなら無し）を消去しておく。
      return false;
    }
    $.ajax({
        url: `/api/categories`,
        type: 'GET',
        data: {
          category_id: category_id
        },
        dataType: 'json',
      })
      .done(function (categories) {
        if (categories.choices.length == 0) { // categoiresがない＝変更されたのは最下層（孫）のカテゴリ
          // ブランドとサイズのフォームを表示する
          if (categories.brand_names != "no_changed") brand_names = categories.brand_names; //
          brand_groups = categories.brand_groups;
          buildBrandAndSizeForm(categories.size_lists);
          return false;
        }
        // ここでのthis(.bind(this)無しの場合) = {url: "/api/categories?category_id=hoge", type: "GET", isLocal: false, global: true, processData: true, …}
        // ここでのthis(.bind(this)有りの場合)  = <select>省略</select>
        // つまりajax前後でのthisを同じ状態にするために.bind(this)が必要。
        // depth 0 = 親カテゴリ 1 = 子カテゴリ 2 = 孫カテゴリ
        let depth = $("select.select-category").index(this);
        // 詳細検索ページかつ変更されたのが子カテゴリの場合、孫カテゴリのフォームをチェックボックス式で作成する。
        if ($("#item_search")[0] && depth == 1) {
          var html = `
                    <div class= "select-category search-form-added">
                      ${buildCollectionForm(categories.choices, "category_id_in")}
                    </div>
                    `
        } else {
          var html = buildCategoryForm(categories.choices) // カテゴリのフォームを組み立ててる。
        }
        $(this).nextAll('.select-category').remove(); // 後続（変更されたのが親カテゴリなら子孫全て、子カテゴリなら孫カテゴリ、孫カテゴリなら無し）を消去しておく。
        $("select.select-category:last").after(html); // カテゴリのフォームたちの一番最後にappendする。
      }.bind(this))
  })
  /////////カテゴリが変更された時ここまで/////////

  //////////////////////////////////////////
  //////////////////////////////////////////
  //////ここから下はサイズやブランド機能用////////
  //////////////////////////////////////////
  //////////////////////////////////////////

  function buildBrandAndSizeForm(size_lists) { // ブランドとサイズのフォームを組み立ててappendする。
    let html = ``;
    if (brand_names.length != 0) { // 選択できるブランドがあった場合、ブランドのフォームを表示する。
      html += `
                    <label for="brand-search__form" class="select-category">ブランド</label>
                    <span class="required-false select-category">任意</span>
                    <div class="select-category" id="brand-search">
                      <input type="text" name="brand_name" id="brand-search__form">
                      <div id="brand-search__result"></div>
                    </div>
                    <div class="error-field select-category" data-column-name="brand"></div>
                    `;
    }
    if (size_lists) { // 選択できるサイズがあった場合、サイズのフォームを表示する。
      html += buildSizeForm(size_lists);
    }
    $("select.select-category:last").nextAll('.select-category').remove();
    $("select.select-category:last").after(html);
  }
  /////////buildBrandAndSizeForm()ここまで/////////

  function buildSizeOption(name, id) { // 渡されてきたデータを使ってoptionタグを組み立てる。
    let option = `
                 <option value="${id}">${name}</option>
                 `
    return option;
  }
  /////////buildSizeOption()ここまで/////////

  function buildSizeForm(size_list, start) { // サイズのフォームを組み立てる。
    let options = `` // optionタグをひとまとめにする入れ物
    size_list.forEach(function (size, index) { // レコードを一つずつ渡してoptionタグを一つずつ組み立てていく。
      options += buildSizeOption(size.name, size.id);
    });
    let html = `
    <label for="size-form" class="select-category">サイズ</label>
    <span class="required-true select-category">必須</span>
    <div class="select-category">
      <select required="required name="item[item_size_attributes][size_id]" id= "size-form">
      <option value="">---</option>
        ${options}
    </div>
    </select>
    `
    return html;
  }
  /////////buildSizeForm()ここまで/////////

  function buildBrandSearchResult(result) { // ブランドのインクリメンタルサーチの結果をhtmlとして組み立てる。
    let brands = ``;
    result.forEach(function (brand, index) {
      brands += `<div class="brand-name">${brand}</div>`
    });
    return brands;
  }
  //buildBrandSearchResult()ここまで

  $(document).on("focus", "#brand-search__form", function () { // 詳細検索ページのブランドフォーム用にブランド名のリストを取得する
    if (brand_names.length == 0) {
      if ($(`.select-category[name="item[category_id]"]`)[0]) {
        var category_id = $(`.select-category[name="item[category_id]"]:last`).val();
      }
      $.ajax({
          url: `/api/brand_names`,
          type: 'GET',
          data: {
            category_id: category_id
          },
          dataType: 'json',
        })
        .done(function (brands) {
          brand_names = brands;
        });
    }
  });
  /////////詳細検索ページのブランドフォーム用にブランド名のリストを取得するここまで/////////

  $(document).on("input", "#brand-search__form", function () { // ブランドのインクリメンタルサーチ
    var input = $(this).val();
    // 検索結果のリセット
    $("#brand-search__result").empty();
    $("#brand-search__result").hide();
    if (!input.match(/\S/g)) return false; // 空文字、スペースのみだったら検索しない。
    var result = [];
    $.each(brand_names, function (index, brand_name) { // 配列brand_namesに対してあいまい検索をかける。
      if (brand_name.indexOf(input) != -1) {
        result.push(brand_name); // ヒットしたブランドを検索結果に加えていく
      }
    });
    if (result.length != 0) { // 検索結果が0じゃない時はhtmlを組み立ててappendする。
      let html = buildBrandSearchResult(result); // 検索結果のHTMLを組み立てる
      $("#brand-search__result").append(html); // 検索結果をappendする。
      $("#brand-search__result").show(); //appendが終わってからdisplay: none;を解除する。
    }
  })
  /////////ブランドのインクリメンタルサーチここまで/////////

  $(document).on('click', function (e) { // インクリメンタルサーチの検索候補をクリックしたかどうか
    if (!$(e.target).closest('#brand-search__result div').length) {
      // ブランドのフォームからフォーカスが外れた時
      // インクリメンタルサーチの非表示
      $("#brand-search__result").empty();
      $("#brand-search__result").hide();
    } else {
      // ブランドの検索結果をクリックした時、検索フォームに反映する。
      var brand_name = $(e.target).text();
      $("#brand-search__form").val(brand_name);
      $(e.target).parent().empty();
      $("#brand-search__result").hide();
    }
  });
  /////////インクリメンタルサーチの検索候補をクリックしたかどうかここまで/////////

  $("#q_category_size_group_name_in").on("change", function () { // size_groupが変更された時
    var input = $(this).val();
    if (!input) {
      $(this).next('.search-checkboxes').remove(); // 既に表示されているサイズフォームをリセット
      return false;
    }
    $.ajax({
        url: `/api/size_groups`,
        type: 'GET',
        data: {
          group_name: input
        },
        dataType: 'json',
      })
      .done(function (lists) {
        let html = buildCollectionForm(lists, "item_size_size_id_in");
        $(this).next('.search-checkboxes').remove(); // 既に表示されているサイズフォームをリセット
        $(this).after(html); // プルダウンメニュー（this）の後ろに追加
      }.bind(this));
  })
  /////////size_groupが変更された時ここまで/////////

});
