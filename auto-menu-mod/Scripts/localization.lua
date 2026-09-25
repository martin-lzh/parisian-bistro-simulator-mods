local translations = {
    en = { 'Auto-compose', 'Menu composed', 'No dishes available', 'Could not compose menu',
        'Maximize the game’s estimated selection rate for this service, using its forecast, weather and event calculations.',
        'Searching %d%% · Cancel', 'Composition cancelled', 'Conditions changed · Try again' },
    ['zh-Hans'] = { '自动组合', '菜单已组合', '没有可选菜品', '组合失败',
        '沿用游戏原生客流、天气和活动计算，最大化当前餐段的预计选择率。',
        '搜索中 %d%% · 点击取消', '已取消组合', '条件已变化，请重新组合' },
    ['zh-Hant'] = { '自動組合', '菜單已組合', '沒有可選菜品', '組合失敗',
        '沿用遊戲原生客流、天氣和活動計算，最大化目前餐段的預計選擇率。',
        '搜尋中 %d%% · 點擊取消', '已取消組合', '條件已變化，請重新組合' },
    fr = { 'Composer le menu', 'Menu composé', 'Aucun plat disponible', 'Composition impossible',
        'Maximiser le taux de sélection estimé par le jeu pour ce service, selon ses prévisions, la météo et les événements.',
        'Recherche %d%% · Annuler', 'Composition annulée', 'Conditions modifiées · Réessayer' },
    it = { 'Componi il menu', 'Menu composto', 'Nessun piatto disponibile', 'Composizione non riuscita',
        'Massimizza il tasso di scelta stimato dal gioco per questo servizio, con le sue previsioni, il meteo e gli eventi.',
        'Ricerca %d%% · Annulla', 'Composizione annullata', 'Condizioni cambiate · Riprova' },
    es = { 'Combinar menú', 'Menú combinado', 'No hay platos disponibles', 'No se pudo combinar',
        'Maximiza la tasa de elección estimada por el juego para este servicio, con sus previsiones, tiempo y eventos.',
        'Buscando %d%% · Cancelar', 'Composición cancelada', 'Condiciones cambiadas · Reintentar' },
    de = { 'Menü zusammenstellen', 'Menü zusammengestellt', 'Keine Gerichte verfügbar', 'Zusammenstellung fehlgeschlagen',
        'Die vom Spiel geschätzte Auswahlrate für diesen Service anhand seiner Prognosen, Wetter- und Ereignisberechnungen maximieren.',
        'Suche %d%% · Abbrechen', 'Zusammenstellung abgebrochen', 'Bedingungen geändert · Erneut versuchen' },
    ru = { 'Составить меню', 'Меню составлено', 'Нет доступных блюд', 'Не удалось составить меню',
        'Максимизировать прогнозируемую игрой вероятность выбора меню с учётом гостей, погоды и событий.',
        'Поиск %d%% · Отмена', 'Составление отменено', 'Условия изменились · Повторить' },
    ja = { '自動で組み合わせ', 'メニューを作成しました', '選択できる料理がありません', 'メニューの作成に失敗しました',
        'ゲーム本来の来客予測・天気・イベントの計算を使い、この時間帯の予想選択率を最大化します。',
        '検索中 %d%% · キャンセル', '作成をキャンセルしました', '条件が変わりました · 再試行' },
    ko = { '메뉴 자동 구성', '메뉴 구성 완료', '선택 가능한 요리 없음', '메뉴 구성 실패',
        '게임의 손님 예측, 날씨 및 행사 계산을 사용해 현재 시간대의 예상 선택률을 최대화합니다.',
        '검색 중 %d%% · 취소', '구성 취소됨', '조건 변경됨 · 다시 시도' },
    tr = { 'Menüyü oluştur', 'Menü oluşturuldu', 'Uygun yemek yok', 'Menü oluşturulamadı',
        'Oyunun müşteri, hava durumu ve etkinlik hesaplamalarıyla bu servisin tahmini seçilme oranını en üst düzeye çıkar.',
        'Aranıyor %d%% · İptal', 'Oluşturma iptal edildi', 'Koşullar değişti · Yeniden dene' },
    pl = { 'Ułóż menu', 'Menu ułożone', 'Brak dostępnych dań', 'Nie udało się ułożyć menu',
        'Zmaksymalizuj przewidywany przez grę wskaźnik wyboru menu, korzystając z jej prognoz gości, pogody i wydarzeń.',
        'Szukanie %d%% · Anuluj', 'Układanie anulowane', 'Warunki zmienione · Spróbuj ponownie' },
    pt = { 'Compor ementa', 'Ementa composta', 'Não há pratos disponíveis', 'Não foi possível compor',
        'Maximizar a taxa de escolha estimada pelo jogo para este serviço, com as suas previsões de clientes, tempo e eventos.',
        'A procurar %d%% · Cancelar', 'Composição cancelada', 'Condições alteradas · Tentar novamente' },
    ['pt-BR'] = { 'Montar cardápio', 'Cardápio montado', 'Nenhum prato disponível', 'Não foi possível montar',
        'Maximizar a taxa de escolha estimada pelo jogo para este serviço, com suas previsões de clientes, clima e eventos.',
        'Buscando %d%% · Cancelar', 'Montagem cancelada', 'Condições alteradas · Tentar novamente' },
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
    return { button = words[1], done = words[2], no_options = words[3], error = words[4], tooltip = words[5],
        searching = words[6], cancelled = words[7], changed = words[8] }
end
