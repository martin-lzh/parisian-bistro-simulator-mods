local labels = {
    en = 'Delivery method', fr = 'Mode de livraison', ['zh-Hans'] = '配送方式',
    it = 'Metodo di consegna', es = 'Método de entrega', de = 'Lieferart',
    ru = 'Способ доставки', ja = '配送方法', ko = '배송 방식', ['zh-Hant'] = '配送方式',
    tr = 'Teslimat yöntemi', pl = 'Sposób dostawy', pt = 'Método de entrega', ['pt-BR'] = 'Método de entrega',
}
return function(language)
    language = tostring(language):gsub('_', '-')
    if language:lower():match('^zh') then
        language = (language:lower():find('hant', 1, true) or language:lower():match('^zh%-tw')
            or language:lower():match('^zh%-hk')) and 'zh-Hant' or 'zh-Hans'
    end
    return labels[language] or labels[language:match('^%a+')] or labels.en
end
