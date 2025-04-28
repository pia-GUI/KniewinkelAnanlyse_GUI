function KniewinkelAnanlyse_GUI
% KnieAngleGUI – GUI zur Analyse des Kniegelenkswinkels aus CSV-Daten.

% Erstes GUI-Fenster zur Auswahl der Kniebeugen-Tiefe und eingabe der
% ProbandenID
hFigSelect = figure('Name','Kniebeugen-Typ wählen','NumberTitle','off',...
    'Position',[300 300 400 250],'WindowStyle','modal');

uicontrol('Style','text','String','Bitte wählen Sie die Kniebeugen-Art:',...
    'Position',[50 170 300 30],'FontSize',10);

hPopupSelect = uicontrol('Style','popupmenu','String',{'Tiefe Kniebeuge','Halbe Kniebeuge','Viertel Kniebeuge','Spezielle Kniebeuge'},...
    'Position',[100 130 200 30]);

uicontrol('Style','text','String','Probanden-ID:',...
    'Position',[50 90 100 20],'FontSize',10);

hEditProbandID = uicontrol('Style','edit','String','',...
    'Position',[160 90 180 25]);

hButtonOK = uicontrol('Style','pushbutton','String','OK',...
    'Position',[150 40 100 30],'Callback',@InfoGUI);

uiwait(hFigSelect);
% zweites GUI Fenster zeigt eine Erklärung, welche Art von Kniebeuge wo für
% gut ist und welcher Winkel erreicht wird 
    function InfoGUI(~,~)
        selectedType = get(hPopupSelect, 'Value');
        probandID = get(hEditProbandID, 'String');
        popupStrings = get(hPopupSelect, 'String');
        selectedTypeText = popupStrings{selectedType};
% Info Texte für die Auswahlmöglichkeiten
        switch selectedType
            case 1
                lowerThreshold = 40;
                upperThreshold = 70;
                message = 'Für eine tiefe Kniebeuge wird ein Schwellenbereich von 40° bis 70° empfohlen. Die tiefe Kniebeuge beschreibt eine Ausführung, bei der die Hüfte unterhalb der Kniehöhe absinkt. In dieser Variante werden insbesondere der Gluteus maximus, die Adduktoren sowie die Vastus-Gruppe des Quadrizeps maximal beansprucht. Die große Bewegungsamplitude sorgt für eine starke Dehnung und Aktivierung dieser Muskelgruppen. Vor allem die unteren Fasern des Gluteus maximus sowie der M. adductor magnus arbeiten hier besonders intensiv. Diese Variante ist besonders effektiv für Muskelaufbau, Mobilität und funktionelle Kraft, da sie viele alltagsrelevante Bewegungen abbildet und durch die tiefe Position eine verbesserte Beweglichkeit fördert.';
            case 2
                lowerThreshold = 80;
                upperThreshold = 100;
                message = 'Für eine halbe Kniebeuge wird ein Schwellenbereich von 80° bis 100° empfohlen. Die halbe Kniebeuge, bei der die Oberschenkel parallel zum Boden verlaufen, aktiviert primär den Quadrizeps und in geringerem Maße den Gluteus. Die Adduktoren sind in dieser Bewegung nur moderat involviert. Diese Variante ist gelenkschonender als die tiefe Kniebeuge und wird häufig im Kraftdreikampf verwendet, da sie eine gute Balance zwischen Kraftentwicklung und technischer Sicherheit bietet. Durch den reduzierten Bewegungsweg können oft höhere Lasten als bei der tiefen Variante bewegt werden, ohne dabei das Risiko für Überlastung zu erhöhen.';
            case 3
                lowerThreshold = 110;
                upperThreshold = 140;
                message = 'Für eine Viertel Kniebeuge wird ein Schwellenbereich von 110° bis 140° empfohlen. Die Viertel-Kniebeuge zeichnet sich durch eine sehr geringe Knieflexion aus. Diese Bewegung aktiviert den Beinbeuger (die ischiocrurale Muskulatur) in höherem Maße als die tiefere Variante, da in diesem Bereich die EMG-Aktivität der Hamstrings am stärksten ist. Der Quadrizeps wird hingegen nur minimal beansprucht. Aufgrund der kurzen Bewegungsamplitude eignet sich diese Form insbesondere für Schnellkrafttraining oder sportartspezifische Reize, etwa in Sprungsportarten. Auch im Rehabilitationsbereich kann sie gezielt eingesetzt werden, um Teilbewegungen zu trainieren, ohne die Gelenke zu stark zu belasten.';
            case 4
                lowerThreshold = 0;
                upperThreshold = 180;
                message = 'Für eine spezielle Kniebeuge wählen Sie bitte einen individuellen Schwellenwert.';
        end

        msgbox(message, 'Empfohlener Schwellenwert', 'help');
        uiwait;
        delete(hFigSelect);
        launchMainGUI(selectedType, lowerThreshold, upperThreshold, probandID, selectedTypeText);
    end
end
% drittes GUI Fenster beinhaltet das Laden der CSV-Datein und die
% Auswertung der Kniebeugen
function launchMainGUI(selectedType, lowerThreshold, upperThreshold, probandID, selectedTypeText)
hFig = figure('Name','Kniegelenkswinkel Analyse','NumberTitle','off',...
    'Position',[100 100 900 600]);

uicontrol('Style','text','String',sprintf('Kniebeugen-Art: %s', selectedTypeText), ...
    'Position',[200 570 400 20], 'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment','left');

uicontrol('Style','pushbutton','String','CSV-Dateien laden',...
    'Position',[20 550 150 30],'Callback',@loadCSVCallback);

uicontrol('Style','text','String','Untere Schwelle (°):',...
    'Position',[200 530 120 20]);

hSliderLower = uicontrol('Style','slider','Min',0,'Max',180,'Value',lowerThreshold,...
    'Position',[330 530 200 20],'Callback',@sliderCallback);

hSliderLowerValue = uicontrol('Style','text','String',sprintf('%.1f°', lowerThreshold),...
    'Position',[540 530 50 20]);

uicontrol('Style','text','String','Obere Schwelle (°):',...
    'Position',[200 500 120 20]);

hSliderUpper = uicontrol('Style','slider','Min',0,'Max',180,'Value',upperThreshold,...
    'Position',[330 500 200 20],'Callback',@sliderCallback);

hSliderUpperValue = uicontrol('Style','text','String',sprintf('%.1f°', upperThreshold),...
    'Position',[540 500 50 20]);

uicontrol('Style','pushbutton','String','Auswertung speichern',...
    'Position',[620 530 150 30],'Callback',@saveResultsCallback);

hAxes = axes('Parent',hFig,'Units','normalized','Position',[0.1 0.1 0.85 0.4]);

% Bestimmung der Position und Farbe der texlichen Rückmeldungen der Kniebeugen
hOutput1 = uicontrol('Style','text','String','', 'Units','normalized',...
    'Position',[0.1 0.74 0.85 0.04],'HorizontalAlignment','left','FontSize',10); %ID
hOutput2 = uicontrol('Style','text','String','', 'Units','normalized',...
    'Position',[0.1 0.70 0.85 0.04],'HorizontalAlignment','left','FontSize',10); %Gesamtanzahl
hOutput3 = uicontrol('Style','text','String','', 'Units','normalized',...
    'Position',[0.1 0.66 0.85 0.04],'HorizontalAlignment','left','FontSize',10,...
    'ForegroundColor',[0 0.5 0]); %Innerhalb (grün)
hOutput4 = uicontrol('Style','text','String','', 'Units','normalized',...
    'Position',[0.1 0.62 0.85 0.04],'HorizontalAlignment','left','FontSize',10,...
    'ForegroundColor','red'); %Unterhalb (rot)
hOutput5 = uicontrol('Style','text','String','', 'Units','normalized',...
    'Position',[0.1 0.58 0.85 0.04],'HorizontalAlignment','left','FontSize',10,...
    'ForegroundColor','red'); %Oberhalb(rot)
hOutput6 = uicontrol('Style','text','String','', 'Units','normalized',...
    'Position',[0.1 0.54 0.85 0.04],'HorizontalAlignment','left','FontSize',10,...
    'ForegroundColor','black');

handles = struct('hAxes', hAxes, 'hSliderLower', hSliderLower, 'hSliderUpper', hSliderUpper, ...
    'hSliderLowerValue', hSliderLowerValue, 'hSliderUpperValue', hSliderUpperValue, ...
    'hOutput1', hOutput1, 'hOutput2', hOutput2, 'hOutput3', hOutput3, ...
    'hOutput4', hOutput4, 'hOutput5', hOutput5, ...
    'hOutput6', hOutput6, 'probandID', probandID, 'selectedTypeText', selectedTypeText);
guidata(hFig, handles);

% Funktion zum Laden der CSV Datein
    function loadCSVCallback(~,~)
        [file1, path1] = uigetfile('*.csv', 'CSV-Datei für Unterschenkel wählen');
        [file2, path2] = uigetfile('*.csv', 'CSV-Datei für Oberschenkel wählen');

        if isequal(file1,0) || isequal(file2,0)
            return;
        end
% Falls es zu einem Fehler kommt erhält der Anwender eine error Mitteilung
        try
            unterschenkel = readtable(fullfile(path1, file1));
            oberschenkel = readtable(fullfile(path2, file2));
        catch ME
            errordlg(['Fehler beim Laden der Dateien: ' ME.message],'Datei-Fehler');
            return;
        end

        unterschenkel.Acc_Diff = [0; abs(diff(unterschenkel.AbsoluteAcceleration_m_s_2_))];
        oberschenkel.Acc_Diff = [0; abs(diff(oberschenkel.AbsoluteAcceleration_m_s_2_))];

        [~, idx_unterschenkel] = max(unterschenkel.Acc_Diff);
        [~, idx_oberschenkel] = max(oberschenkel.Acc_Diff);

        time_sync_unterschenkel = unterschenkel.Time_s_(idx_unterschenkel);
        time_sync_oberschenkel = oberschenkel.Time_s_(idx_oberschenkel);

        unterschenkel.Time_Sync = unterschenkel.Time_s_ - time_sync_unterschenkel;
        oberschenkel.Time_Sync = oberschenkel.Time_s_ - time_sync_oberschenkel;

        time_min = max(min(unterschenkel.Time_Sync), min(oberschenkel.Time_Sync));
        time_max = min(max(unterschenkel.Time_Sync), max(oberschenkel.Time_Sync));

        unterschenkel.Theta = smoothdata(atan2d(unterschenkel.AccelerationY_m_s_2_, unterschenkel.AccelerationX_m_s_2_), 'movmean', 5);
        oberschenkel.Theta = smoothdata(atan2d(oberschenkel.AccelerationY_m_s_2_, oberschenkel.AccelerationX_m_s_2_), 'movmean', 5);

        common_time = time_min:0.01:time_max;
        theta_unterschenkel_interp = interp1(unterschenkel.Time_Sync, unterschenkel.Theta, common_time, 'linear', 'extrap');
        theta_oberschenkel_interp = interp1(oberschenkel.Time_Sync, oberschenkel.Theta, common_time, 'linear', 'extrap');

        kniewinkel = 180 - abs(theta_oberschenkel_interp - theta_unterschenkel_interp);

        valid_indices = common_time > 2;
        common_time = common_time(valid_indices);
        kniewinkel = kniewinkel(valid_indices);

        handles = guidata(hFig);
        handles.common_time = common_time;
        handles.kniewinkel = kniewinkel;
        handles.probandID = probandID;
        guidata(hFig, handles);

        updatePlot();
    end
% Entsprechend der gewählten Kniebeugentiefe werden die Silder gesetzt 
    function sliderCallback(~,~)
        lowerVal = get(hSliderLower, 'Value');
        upperVal = get(hSliderUpper, 'Value');
        set(hSliderLowerValue, 'String', sprintf('%.1f°', lowerVal));
        set(hSliderUpperValue, 'String', sprintf('%.1f°', upperVal));
        updatePlot();
    end

% Anpassung der gestrichelten Linie im Plot zur viesuellen Darstellung der
% Schwellwerte 
    function updatePlot()
        handles = guidata(hFig);
        if ~isfield(handles, 'kniewinkel')
            return;
        end
        lowerThreshold = get(handles.hSliderLower, 'Value');
        upperThreshold = get(handles.hSliderUpper, 'Value');
        common_time = handles.common_time;
        kniewinkel = handles.kniewinkel;

        axes(handles.hAxes);
        cla;
        plot(common_time, kniewinkel, 'b', 'LineWidth', 1.5);
        hold on;
        yline(lowerThreshold, 'r--', sprintf('Untere Schwelle = %.1f°', lowerThreshold));
        yline(upperThreshold, 'r--', sprintf('Obere Schwelle = %.1f°', upperThreshold));

 % Minima finden (tiefster Punkt der Kniebeuge) 
        [~, locs] = findpeaks(-kniewinkel, 'MinPeakDistance', 130, 'MinPeakProminence', 25);
        valid_times_minima = common_time(locs);
        valid_minima = kniewinkel(locs);

% Berechnung des durchschnittlichen Kniewinkels (nur Minima)
average_minimum = mean(valid_minima);

% Bestimmung der Anzahöl der Kniebeugen, inner-, unter- oder oberhalb der
% Schwellwerte
        below_range = valid_minima < lowerThreshold;
        within_range = (valid_minima >= lowerThreshold) & (valid_minima <= upperThreshold);
        above_range = valid_minima > upperThreshold;
% Farbliche markierung der Minima 
        plot(valid_times_minima(below_range), valid_minima(below_range), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
        plot(valid_times_minima(within_range), valid_minima(within_range), 'go', 'MarkerSize', 8, 'LineWidth', 1.5);
        plot(valid_times_minima(above_range), valid_minima(above_range), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);

        xlabel('Zeit (s)');
        ylabel('Kniegelenkswinkel (°)');
        title('Kniegelenkswinkel über die Zeit');
        grid on;
        hold off;
% zählen der Kniebeugen
        total_squats = length(valid_minima);
        below_threshold = sum(below_range);
        above_threshold = sum(above_range);
        within_threshold = sum(within_range);
% texliche Darstellung der Analyse
        set(handles.hOutput1, 'String', sprintf('Probanden-ID: %s', handles.probandID));
        set(handles.hOutput2, 'String', sprintf('Gesamtanzahl der Kniebeugen: %d', total_squats));
        set(handles.hOutput3, 'String', sprintf('Innerhalb der Schwellenwerte: %d', within_threshold));
        set(handles.hOutput4, 'String', sprintf('Unterhalb der Schwellenwerte: %d', below_threshold));
        set(handles.hOutput5, 'String', sprintf('Oberhalb der Schwellenwerte: %d', above_threshold));
        set(handles.hOutput6, 'String', sprintf('Durchschnittlicher Kniewinkel (Minima): %.1f°', average_minimum));

        handles.output_str = sprintf('Probanden-ID: %s\nKniebeugen-Art: %s\nGesamtanzahl der Kniebeugen: %d\nInnerhalb der Schwellenwerte: %d\nUnterhalb der Schwellenwerte: %d\nOberhalb der Schwellenwerte: %d\nDurchschnittlicher Kniewinkel (Minima): %.1f°', ...
            handles.probandID, handles.selectedTypeText, total_squats, within_threshold, below_threshold, above_threshold, average_minimum);
        guidata(hFig, handles);
    end
% Funkion zum speichern der Daten als .txt auf dem PC
    function saveResultsCallback(~,~)
        handles = guidata(hFig);
        if isfield(handles, 'output_str')
            [file,path] = uiputfile('*.txt','Speichern unter');
            if isequal(file,0)
                return;
            end
            fid = fopen(fullfile(path, file), 'w');
% Rückmeldung, ob das Speichern erolgreich war oder nicht
            if fid ~= -1
                fprintf(fid, '%s', handles.output_str);
                fclose(fid);
                msgbox('Auswertung erfolgreich gespeichert.', 'Erfolg');
            else
                errordlg('Fehler beim Speichern der Datei.', 'Dateifehler');
            end
        end
    end
end
