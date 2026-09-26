-- Original Mod messages only. Game notifications and interaction text remain native.
local Localization = {}
Localization.__index = Localization

local messages = {
    en = {
        host_active = 'Host checkout active.',
        ai_restore_failed = 'AI task restoration failed; reload the world.',
        ai_schedule_failed = 'Cannot schedule AI task restoration; reload the world.',
        stopped = 'Stopped after an error; manual checkout remains available.',
        notification_unavailable = 'Billing notification listener unavailable; polling remains active.',
        no_progress = 'No progress after three requests; leaving this stage to manual checkout.',
    },
    fr = {
        host_active = "Encaissement automatique actif pour l’hôte.",
        ai_restore_failed = 'Échec de la restauration des tâches des employés ; rechargez le monde.',
        ai_schedule_failed = 'Impossible de planifier la restauration des tâches des employés ; rechargez le monde.',
        stopped = 'Arrêt après une erreur ; l’encaissement manuel reste disponible.',
        notification_unavailable = 'Écoute des notifications de caisse indisponible ; les vérifications périodiques continuent.',
        no_progress = 'Aucune progression après trois requêtes ; terminez cette étape manuellement.',
    },
    ['zh-Hans'] = {
        host_active = '房主自动结账已启用。',
        ai_restore_failed = '员工任务恢复失败；请重新载入世界。',
        ai_schedule_failed = '无法安排员工任务恢复；请重新载入世界。',
        stopped = '发生错误，自动结账已停止；仍可手动结账。',
        notification_unavailable = '柜台提醒监听不可用；定时检查继续运行。',
        no_progress = '三次请求后仍无进展；请手动完成此步骤。',
    },
    it = {
        host_active = 'Pagamento automatico attivo per l’host.',
        ai_restore_failed = 'Ripristino delle mansioni dei dipendenti non riuscito; ricarica il mondo.',
        ai_schedule_failed = 'Impossibile pianificare il ripristino delle mansioni dei dipendenti; ricarica il mondo.',
        stopped = 'Arresto dopo un errore; il pagamento manuale resta disponibile.',
        notification_unavailable = 'Ascolto delle notifiche di cassa non disponibile; i controlli periodici continuano.',
        no_progress = 'Nessun avanzamento dopo tre richieste; completa questo passaggio manualmente.',
    },
    es = {
        host_active = 'Cobro automático activo para el anfitrión.',
        ai_restore_failed = 'No se pudieron restaurar las tareas de los empleados; vuelve a cargar el mundo.',
        ai_schedule_failed = 'No se pudo programar la restauración de las tareas de los empleados; vuelve a cargar el mundo.',
        stopped = 'Detenido tras un error; el cobro manual sigue disponible.',
        notification_unavailable = 'La escucha de avisos de caja no está disponible; las comprobaciones periódicas continúan.',
        no_progress = 'Sin progreso tras tres solicitudes; completa este paso manualmente.',
    },
    de = {
        host_active = 'Automatisches Kassieren für den Host aktiv.',
        ai_restore_failed = 'Mitarbeiteraufgaben konnten nicht wiederhergestellt werden; lade die Welt neu.',
        ai_schedule_failed = 'Wiederherstellung der Mitarbeiteraufgaben konnte nicht eingeplant werden; lade die Welt neu.',
        stopped = 'Nach einem Fehler angehalten; manuelles Kassieren bleibt möglich.',
        notification_unavailable = 'Kassenbenachrichtigungen können nicht empfangen werden; regelmäßige Prüfungen laufen weiter.',
        no_progress = 'Nach drei Anfragen kein Fortschritt; schließe diesen Schritt manuell ab.',
    },
    ru = {
        host_active = 'Автоматический расчёт у кассы включён для хоста.',
        ai_restore_failed = 'Не удалось восстановить задачи сотрудников; перезагрузите мир.',
        ai_schedule_failed = 'Не удалось запланировать восстановление задач сотрудников; перезагрузите мир.',
        stopped = 'Остановка из-за ошибки; ручной расчёт по-прежнему доступен.',
        notification_unavailable = 'Получение уведомлений кассы недоступно; периодические проверки продолжаются.',
        no_progress = 'После трёх запросов нет изменений; завершите этот этап вручную.',
    },
    ja = {
        host_active = 'ホストの自動会計が有効になりました。',
        ai_restore_failed = '従業員のタスクを復元できませんでした。ワールドを再読み込みしてください。',
        ai_schedule_failed = '従業員のタスクの復元を予約できませんでした。ワールドを再読み込みしてください。',
        stopped = 'エラーにより自動会計を停止しました。手動での会計は引き続き可能です。',
        notification_unavailable = 'レジ通知を受信できません。定期チェックは継続します。',
        no_progress = '3回要求しても進行しませんでした。この手順を手動で完了してください。',
    },
    ko = {
        host_active = '호스트의 자동 계산이 활성화되었습니다.',
        ai_restore_failed = '직원 작업을 복원하지 못했습니다. 월드를 다시 불러오세요.',
        ai_schedule_failed = '직원 작업 복원을 예약할 수 없습니다. 월드를 다시 불러오세요.',
        stopped = '오류로 자동 계산이 중지되었습니다. 수동 계산은 계속 가능합니다.',
        notification_unavailable = '계산대 알림을 수신할 수 없습니다. 주기적인 확인은 계속됩니다.',
        no_progress = '세 번 요청한 후에도 진행되지 않았습니다. 이 단계를 수동으로 완료하세요.',
    },
    ['zh-Hant'] = {
        host_active = '房主自動結帳已啟用。',
        ai_restore_failed = '員工任務恢復失敗；請重新載入世界。',
        ai_schedule_failed = '無法安排員工任務恢復；請重新載入世界。',
        stopped = '發生錯誤，自動結帳已停止；仍可手動結帳。',
        notification_unavailable = '櫃台提醒監聽不可用；定時檢查繼續執行。',
        no_progress = '三次請求後仍無進展；請手動完成此步驟。',
    },
    tr = {
        host_active = 'Oyun sahibi için otomatik hesap ödeme etkin.',
        ai_restore_failed = 'Çalışan görevleri geri yüklenemedi; dünyayı yeniden yükleyin.',
        ai_schedule_failed = 'Çalışan görevlerinin geri yüklenmesi planlanamadı; dünyayı yeniden yükleyin.',
        stopped = 'Bir hatadan sonra durduruldu; elle hesap ödeme hâlâ kullanılabilir.',
        notification_unavailable = 'Kasa bildirimleri dinlenemiyor; düzenli kontroller devam ediyor.',
        no_progress = 'Üç isteğin ardından ilerleme olmadı; bu adımı elle tamamlayın.',
    },
    pl = {
        host_active = 'Automatyczna obsługa płatności jest aktywna dla gospodarza.',
        ai_restore_failed = 'Nie udało się przywrócić zadań pracowników; wczytaj świat ponownie.',
        ai_schedule_failed = 'Nie można zaplanować przywrócenia zadań pracowników; wczytaj świat ponownie.',
        stopped = 'Zatrzymano po błędzie; ręczna obsługa płatności jest nadal dostępna.',
        notification_unavailable = 'Odbieranie powiadomień kasy jest niedostępne; okresowe sprawdzanie jest kontynuowane.',
        no_progress = 'Brak postępu po trzech żądaniach; wykonaj ten etap ręcznie.',
    },
    pt = {
        host_active = 'Pagamento automático ativo para o anfitrião.',
        ai_restore_failed = 'Não foi possível restaurar as tarefas dos funcionários; volta a carregar o mundo.',
        ai_schedule_failed = 'Não foi possível agendar a restauração das tarefas dos funcionários; volta a carregar o mundo.',
        stopped = 'Interrompido após um erro; o pagamento manual continua disponível.',
        notification_unavailable = 'Não é possível receber notificações da caixa; as verificações periódicas continuam.',
        no_progress = 'Sem progresso após três pedidos; conclui este passo manualmente.',
    },
    ['pt-BR'] = {
        host_active = 'Pagamento automático ativo para o anfitrião.',
        ai_restore_failed = 'Não foi possível restaurar as tarefas dos funcionários; recarregue o mundo.',
        ai_schedule_failed = 'Não foi possível agendar a restauração das tarefas dos funcionários; recarregue o mundo.',
        stopped = 'Interrompido após um erro; o pagamento manual continua disponível.',
        notification_unavailable = 'Não é possível receber notificações do caixa; as verificações periódicas continuam.',
        no_progress = 'Sem progresso após três solicitações; conclua esta etapa manualmente.',
    },
}

function Localization.normalize(culture)
    if type(culture) ~= 'string' then return 'en' end
    local tag = culture:lower():gsub('_', '-'):match('^%s*(.-)%s*$')
    if not tag:match('^[a-z][a-z0-9%-]*$') or tag:find('--', 1, true)
        or tag:sub(-1) == '-' then return 'en' end
    local language = tag:match('^([a-z]+)%-') or tag:match('^([a-z]+)$')
    if language == 'zh' then
        -- An explicit script takes priority over a potentially conflicting region.
        for part in tag:gmatch('[^-]+') do
            if part == 'hans' then return 'zh-Hans' end
            if part == 'hant' then return 'zh-Hant' end
        end
        for part in tag:gmatch('[^-]+') do
            if part == 'tw' or part == 'hk' or part == 'mo' then return 'zh-Hant' end
        end
        return 'zh-Hans'
    end
    if tag == 'pt-br' or tag:match('^pt%-br%-') then return 'pt-BR' end
    return messages[language] and language or 'en'
end

function Localization.new()
    return setmetatable({ language = 'en' }, Localization)
end

function Localization:refresh(read_language)
    -- Locale failures must never stop checkout or retain a language from an old world.
    local ok, culture = pcall(read_language)
    self.language = Localization.normalize(ok and culture or nil)
end

function Localization:text(key)
    local values = messages[self.language] or messages.en
    return values[key] or messages.en[key] or key
end

return Localization
