# Diagramy architektury SOK.NET

Ten folder zawiera diagramy architektury systemu SOK.NET stworzone przy użyciu [Structurizr](https://structurizr.com/) - narzędzia do wizualizacji architektury oprogramowania w notacji C4.

## Struktura plików

- **`workspace.dsl`** - plik źródłowy definiujący model architektury (wersjonowany w Git)
- `workspace.json` - plik generowany automatycznie przez Structurizr Lite (ignorowany przez Git)
- `.structurizr/` - folder cache'u i indeksu (ignorowany przez Git)

## Uruchamianie Structurizr Lite

### Wymagania

- Docker

### Uruchomienie

W VS Code możesz użyć predefiniowanego taska:

1. Naciśnij `Ctrl+Shift+P` (lub `Cmd+Shift+P` na macOS)
2. Wpisz "Run Task" i wybierz "Tasks: Run Task"
3. Wybierz "Structurizr Lite Up"

Alternatywnie, uruchom w terminalu z katalogu głównego projektu:

```bash
docker run -it --rm -p 9000:8080 -v ./diagrams:/usr/local/structurizr structurizr/lite
```

Następnie otwórz przeglądarkę pod adresem: [http://localhost:9000](http://localhost:9000)

## Edycja diagramów

1. Uruchom Structurizr Lite (patrz wyżej)
2. Edytuj plik `workspace.dsl` w edytorze
3. Zapisz zmiany - Structurizr Lite automatycznie odświeży widok w przeglądarce
4. Możesz także edytować układ diagramów bezpośrednio w interfejsie webowym

## Eksportowanie diagramów do LaTeX

### Metoda 1: Eksport PNG (zalecana)

1. W interfejsie Structurizr Lite otwórz wybrany diagram
2. Kliknij ikonę eksportu (zazwyczaj w prawym górnym rogu)
3. Wybierz "Export to PNG"
4. Zapisz plik w odpowiednim folderze projektu LaTeX (np. `figures/`)
5. Wstaw do dokumentu LaTeX:

```latex
\begin{figure}[h]
    \centering
    \includegraphics[width=\textwidth]{figures/diagram1.png}
    \caption{Diagram kontekstu systemu}
    \label{fig:diagram1}
\end{figure}
```

### Metoda 2: Eksport SVG

1. Wyeksportuj diagram jako SVG
2. Zapisz w folderze projektu
3. Upewnij się, że w preambule LaTeX masz:

```latex
\usepackage{svg}
```

4. Wstaw diagram:

```latex
\begin{figure}[h]
    \centering
    \includesvg[width=\textwidth]{figures/diagram1}
    \caption{Diagram kontekstu systemu}
    \label{fig:diagram1}
\end{figure}
```

## Dostępne diagramy

Model zawiera następujące widoki (zdefiniowane w sekcji `views` pliku DSL):

- **Diagram1** - Diagram kontekstu systemu (System Context)
- **Diagram2** - Diagram kontenerów (Containers)
- **Diagram3** - Diagram komponentów aplikacji webowej (Components - Web App)
- **Diagram4** - Diagram komponentów aplikacji API (Components - API App)

## Więcej informacji

- [Structurizr DSL - dokumentacja](https://github.com/structurizr/dsl)
- [C4 Model](https://c4model.com/) - notacja używana w diagramach
- [Structurizr Lite](https://structurizr.com/help/lite) - dokumentacja narzędzia
