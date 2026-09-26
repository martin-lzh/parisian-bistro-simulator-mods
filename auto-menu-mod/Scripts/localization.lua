local translations = {
    en = { 'Auto-compose',
        'Maximize the game’s estimated selection rate for this service, using its forecast, weather and event calculations.' },
    ['zh-Hans'] = { '自动组合',
        '沿用游戏原生客流、天气和活动计算，最大化当前餐段的预计选择率。' },
    ['zh-Hant'] = { '自動組合',
        '沿用遊戲原生客流、天氣和活動計算，最大化目前餐段的預計選擇率。' },
    fr = { 'Composer le menu',
        'Maximiser le taux de sélection estimé par le jeu pour ce service, selon ses prévisions, la météo et les événements.' },
    it = { 'Componi il menu',
        'Massimizza il tasso di scelta stimato dal gioco per questo servizio, con le sue previsioni, il meteo e gli eventi.' },
    es = { 'Combinar menú',
        'Maximiza la tasa de elección estimada por el juego para este servicio, con sus previsiones, tiempo y eventos.' },
    de = { 'Menü zusammenstellen',
        'Die vom Spiel geschätzte Auswahlrate für diesen Service anhand seiner Prognosen, Wetter- und Ereignisberechnungen maximieren.' },
    ru = { 'Составить меню',
        'Максимизировать прогнозируемую игрой вероятность выбора меню с учётом гостей, погоды и событий.' },
    ja = { '自動で組み合わせ',
        'ゲーム本来の来客予測・天気・イベントの計算を使い、この時間帯の予想選択率を最大化します。' },
    ko = { '메뉴 자동 구성',
        '게임의 손님 예측, 날씨 및 행사 계산을 사용해 현재 시간대의 예상 선택률을 최대화합니다.' },
    tr = { 'Menüyü oluştur',
        'Oyunun müşteri, hava durumu ve etkinlik hesaplamalarıyla bu servisin tahmini seçilme oranını en üst düzeye çıkar.' },
    pl = { 'Ułóż menu',
        'Zmaksymalizuj przewidywany przez grę wskaźnik wyboru menu, korzystając z jej prognoz gości, pogody i wydarzeń.' },
    pt = { 'Compor ementa',
        'Maximizar a taxa de escolha estimada pelo jogo para este serviço, com as suas previsões de clientes, tempo e eventos.' },
    ['pt-BR'] = { 'Montar cardápio',
        'Maximizar a taxa de escolha estimada pelo jogo para este serviço, com suas previsões de clientes, clima e eventos.' },
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
    return { button = words[1], tooltip = words[2] }
end
