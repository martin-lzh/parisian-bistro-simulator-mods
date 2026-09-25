local translations = {
    en = { 'Auto-compose', 'Menu composed', 'No dishes available', 'Could not compose menu',
        'Match this service to the customer forecast, weather and local event.' },
    ['zh-Hans'] = { '自动组合', '菜单已组合', '没有可选菜品', '组合失败',
        '根据预测客流喜好、天气及活动，为当前餐段组合每日菜单。' },
    ['zh-Hant'] = { '自動組合', '菜單已組合', '沒有可選菜品', '組合失敗',
        '根據預測客流喜好、天氣及活動，為目前餐段組合每日菜單。' },
    fr = { 'Composer le menu', 'Menu composé', 'Aucun plat disponible', 'Composition impossible',
        'Adapter ce service aux prévisions de clientèle, à la météo et à l’événement local.' },
    it = { 'Componi il menu', 'Menu composto', 'Nessun piatto disponibile', 'Composizione non riuscita',
        'Adatta questo servizio alle previsioni dei clienti, al meteo e all’evento locale.' },
    es = { 'Combinar menú', 'Menú combinado', 'No hay platos disponibles', 'No se pudo combinar',
        'Adapta este servicio a la previsión de clientes, al tiempo y al evento local.' },
    de = { 'Menü zusammenstellen', 'Menü zusammengestellt', 'Keine Gerichte verfügbar', 'Zusammenstellung fehlgeschlagen',
        'Dieses Menü an Gästeprognose, Wetter und lokale Veranstaltung anpassen.' },
    ru = { 'Составить меню', 'Меню составлено', 'Нет доступных блюд', 'Не удалось составить меню',
        'Подобрать меню с учётом прогноза гостей, погоды и местного события.' },
    ja = { '自動で組み合わせ', 'メニューを作成しました', '選択できる料理がありません', 'メニューの作成に失敗しました',
        '来客予測の好み、天気、地域のイベントに合わせて現在の時間帯のメニューを組みます。' },
    ko = { '메뉴 자동 구성', '메뉴 구성 완료', '선택 가능한 요리 없음', '메뉴 구성 실패',
        '예상 손님 취향, 날씨 및 지역 행사에 맞춰 현재 시간대의 메뉴를 구성합니다.' },
    tr = { 'Menüyü oluştur', 'Menü oluşturuldu', 'Uygun yemek yok', 'Menü oluşturulamadı',
        'Bu servisi müşteri tahminine, hava durumuna ve yerel etkinliğe göre düzenle.' },
    pl = { 'Ułóż menu', 'Menu ułożone', 'Brak dostępnych dań', 'Nie udało się ułożyć menu',
        'Dopasuj menu do prognozy gości, pogody i lokalnego wydarzenia.' },
    pt = { 'Compor ementa', 'Ementa composta', 'Não há pratos disponíveis', 'Não foi possível compor',
        'Adaptar este serviço à previsão de clientes, ao tempo e ao evento local.' },
    ['pt-BR'] = { 'Montar cardápio', 'Cardápio montado', 'Nenhum prato disponível', 'Não foi possível montar',
        'Adaptar este serviço à previsão de clientes, ao clima e ao evento local.' },
}

return function(language)
    local code = tostring(language):lower():gsub('_', '-')
    if code:match('^zh') then
        if code:find('hans', 1, true) then code = 'zh-Hans'
        elseif code:find('hant', 1, true) or code:match('^zh%-tw')
            or code:match('^zh%-hk') or code:match('^zh%-mo') then code = 'zh-Hant'
        else code = 'zh-Hans' end
    elseif code:match('^pt%-br') then code = 'pt-BR'
    else code = code:match('^%a+') end
    local words = translations[code] or translations.en
    return { button = words[1], done = words[2], no_options = words[3], error = words[4], tooltip = words[5] }
end
