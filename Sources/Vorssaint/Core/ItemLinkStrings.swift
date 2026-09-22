// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct ItemLinkFeatureStrings {
    let title: String
    let description: String
    let enable: String
    let caption: String
    let shortcut: String
    let copiedFormat: String
    let failed: String
    let automationPermission: String
    let automationExplanation: String
}

extension FeatureStrings {
    static func itemLinks(_ language: AppLanguage) -> ItemLinkFeatureStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        }
    }
}

extension ItemLinkFeatureStrings {
    static let enUS = ItemLinkFeatureStrings(
        title: "Copy item link",
        description: "Copy direct links to selected messages in Mail and notes in Apple Notes.",
        enable: "Copy Mail and Notes links",
        caption: "The shortcut acts on selected items in Mail and Notes. Notes links require Full Disk Access; note contents are never read.",
        shortcut: "Copy item link",
        copiedFormat: "%d link(s) copied",
        failed: "No item link found",
        automationPermission: "Automation · Mail and Notes",
        automationExplanation: "Reads the items you selected so their direct links can be copied."
    )
    static let ptBR = ItemLinkFeatureStrings(
        title: "Copiar link do item", description: "Copie links diretos de mensagens selecionadas no Mail e notas no Apple Notes.",
        enable: "Copiar links do Mail e Notas", caption: "O atalho funciona nos itens selecionados no Mail e Notas. Links de notas exigem Acesso Total ao Disco; o conteúdo das notas nunca é lido.",
        shortcut: "Copiar link do item", copiedFormat: "%d link(s) copiado(s)", failed: "Nenhum link de item encontrado",
        automationPermission: "Automação · Mail e Notas", automationExplanation: "Lê os itens selecionados para copiar seus links diretos."
    )
    static let tr = ItemLinkFeatureStrings(
        title: "Öğe bağlantısını kopyala", description: "Mail’de seçili iletilerin ve Apple Notlar’daki notların doğrudan bağlantılarını kopyalayın.",
        enable: "Mail ve Notlar bağlantılarını kopyala", caption: "Kısayol Mail ve Notlar’daki seçili öğelerde çalışır. Not bağlantıları Tam Disk Erişimi gerektirir; not içeriği hiçbir zaman okunmaz.",
        shortcut: "Öğe bağlantısını kopyala", copiedFormat: "%d bağlantı kopyalandı", failed: "Öğe bağlantısı bulunamadı",
        automationPermission: "Otomasyon · Mail ve Notlar", automationExplanation: "Doğrudan bağlantılarını kopyalamak için seçtiğiniz öğeleri okur."
    )
    static let ru = ItemLinkFeatureStrings(
        title: "Копировать ссылку на объект", description: "Копируйте прямые ссылки на выбранные письма в Mail и заметки в Apple Notes.",
        enable: "Копировать ссылки Mail и Заметок", caption: "Сочетание действует на выбранные объекты в Mail и Заметках. Для ссылок на заметки нужен полный доступ к диску; содержимое заметок не читается.",
        shortcut: "Копировать ссылку", copiedFormat: "Скопировано ссылок: %d", failed: "Ссылка на объект не найдена",
        automationPermission: "Автоматизация · Mail и Заметки", automationExplanation: "Читает выбранные объекты, чтобы скопировать прямые ссылки на них."
    )
    static let es = ItemLinkFeatureStrings(
        title: "Copiar enlace del elemento", description: "Copia enlaces directos a mensajes seleccionados en Mail y notas en Apple Notes.",
        enable: "Copiar enlaces de Mail y Notas", caption: "El atajo actúa sobre los elementos seleccionados en Mail y Notas. Los enlaces de notas requieren acceso total al disco; nunca se lee su contenido.",
        shortcut: "Copiar enlace del elemento", copiedFormat: "%d enlace(s) copiado(s)", failed: "No se encontró ningún enlace",
        automationPermission: "Automatización · Mail y Notas", automationExplanation: "Lee los elementos seleccionados para copiar sus enlaces directos."
    )
    static let de = ItemLinkFeatureStrings(
        title: "Objektlink kopieren", description: "Kopiere direkte Links zu ausgewählten Nachrichten in Mail und Notizen in Apple Notizen.",
        enable: "Mail- und Notizen-Links kopieren", caption: "Der Kurzbefehl wirkt auf ausgewählte Objekte in Mail und Notizen. Notizlinks benötigen Festplattenvollzugriff; Notizinhalte werden nie gelesen.",
        shortcut: "Objektlink kopieren", copiedFormat: "%d Link(s) kopiert", failed: "Kein Objektlink gefunden",
        automationPermission: "Automation · Mail und Notizen", automationExplanation: "Liest die ausgewählten Objekte, um ihre direkten Links zu kopieren."
    )
    static let fr = ItemLinkFeatureStrings(
        title: "Copier le lien de l’élément", description: "Copiez les liens directs des messages sélectionnés dans Mail et des notes dans Apple Notes.",
        enable: "Copier les liens de Mail et Notes", caption: "Le raccourci agit sur les éléments sélectionnés dans Mail et Notes. Les liens de notes exigent l’accès complet au disque ; leur contenu n’est jamais lu.",
        shortcut: "Copier le lien de l’élément", copiedFormat: "%d lien(s) copié(s)", failed: "Aucun lien d’élément trouvé",
        automationPermission: "Automatisation · Mail et Notes", automationExplanation: "Lit les éléments sélectionnés afin de copier leurs liens directs."
    )
    static let it = ItemLinkFeatureStrings(
        title: "Copia link elemento", description: "Copia i link diretti ai messaggi selezionati in Mail e alle note in Apple Note.",
        enable: "Copia link di Mail e Note", caption: "L’abbreviazione agisce sugli elementi selezionati in Mail e Note. I link delle note richiedono Accesso completo al disco; il contenuto non viene mai letto.",
        shortcut: "Copia link elemento", copiedFormat: "%d link copiato/i", failed: "Nessun link trovato",
        automationPermission: "Automazione · Mail e Note", automationExplanation: "Legge gli elementi selezionati per copiarne i link diretti."
    )
    static let ja = ItemLinkFeatureStrings(
        title: "項目のリンクをコピー", description: "メールで選択したメッセージとApple Notesのメモへの直接リンクをコピーします。",
        enable: "メールとメモのリンクをコピー", caption: "ショートカットはメールとメモで選択した項目に作用します。メモのリンクにはフルディスクアクセスが必要ですが、本文は読み取りません。",
        shortcut: "項目のリンクをコピー", copiedFormat: "%d件のリンクをコピーしました", failed: "項目のリンクが見つかりません",
        automationPermission: "オートメーション・メールとメモ", automationExplanation: "選択した項目を読み取り、直接リンクをコピーします。"
    )
    static let ko = ItemLinkFeatureStrings(
        title: "항목 링크 복사", description: "Mail에서 선택한 메시지와 Apple 메모에서 선택한 메모의 직접 링크를 복사합니다.",
        enable: "Mail 및 메모 링크 복사", caption: "단축키는 Mail과 메모에서 선택한 항목에 작동합니다. 메모 링크에는 전체 디스크 접근 권한이 필요하며 메모 내용은 읽지 않습니다.",
        shortcut: "항목 링크 복사", copiedFormat: "링크 %d개 복사됨", failed: "항목 링크를 찾을 수 없음",
        automationPermission: "자동화 · Mail 및 메모", automationExplanation: "직접 링크를 복사하기 위해 선택한 항목을 읽습니다."
    )
    static let zhHans = ItemLinkFeatureStrings(
        title: "拷贝项目链接", description: "拷贝“邮件”中所选邮件和 Apple 备忘录中所选备忘录的直接链接。",
        enable: "拷贝邮件和备忘录链接", caption: "快捷键作用于“邮件”和“备忘录”中的所选项目。备忘录链接需要完全磁盘访问权限；绝不会读取备忘录内容。",
        shortcut: "拷贝项目链接", copiedFormat: "已拷贝 %d 个链接", failed: "未找到项目链接",
        automationPermission: "自动化 · 邮件和备忘录", automationExplanation: "读取所选项目以拷贝其直接链接。"
    )
    static let zhTW = ItemLinkFeatureStrings(
        title: "拷貝項目連結", description: "拷貝「郵件」中所選郵件和 Apple 備忘錄中所選備忘錄的直接連結。",
        enable: "拷貝郵件與備忘錄連結", caption: "快捷鍵會作用於「郵件」和「備忘錄」中的所選項目。備忘錄連結需要完整磁碟取用權；絕不會讀取備忘錄內容。",
        shortcut: "拷貝項目連結", copiedFormat: "已拷貝 %d 個連結", failed: "找不到項目連結",
        automationPermission: "自動化 · 郵件與備忘錄", automationExplanation: "讀取所選項目以拷貝其直接連結。"
    )
    static let zhHK = ItemLinkFeatureStrings(
        title: "複製項目連結", description: "複製「郵件」中所選郵件和 Apple 備忘錄中所選備忘錄的直接連結。",
        enable: "複製郵件與備忘錄連結", caption: "快捷鍵會用於「郵件」和「備忘錄」中的所選項目。備忘錄連結需要完整磁碟取用權；絕不會讀取備忘錄內容。",
        shortcut: "複製項目連結", copiedFormat: "已複製 %d 個連結", failed: "找不到項目連結",
        automationPermission: "自動化 · 郵件與備忘錄", automationExplanation: "讀取所選項目以複製其直接連結。"
    )
}
