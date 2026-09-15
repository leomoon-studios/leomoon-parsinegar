// Copyright (c) 2026 LeoMoon Studios
var SourceHistory = (function () {
    "use strict";

    function boundedInteger(value, fallback, minimum, maximum) {
        var number = Number(value);
        if (!isFinite(number)) number = fallback;
        number = Math.floor(number);
        return Math.max(minimum, Math.min(maximum, number));
    }

    function state(value) {
        var text = String(value && value.text !== undefined ? value.text : "");
        return {
            text: text,
            cursor: boundedInteger(value && value.cursor, 0, 0, text.length),
            anchor: boundedInteger(value && value.anchor, value && value.cursor, 0, text.length)
        };
    }

    function create(initialState, limit) {
        return {
            limit: boundedInteger(limit, 100, 1, 1000),
            undo: [],
            redo: [],
            current: state(initialState)
        };
    }

    function rebuild(history, undo, redo, current) {
        return {
            limit: history.limit,
            undo: undo,
            redo: redo,
            current: state(current)
        };
    }

    function trim(entries, limit) {
        return entries.length <= limit ? entries : entries.slice(entries.length - limit);
    }

    function updateSelection(history, cursor, anchor) {
        var current = state({ text: history.current.text, cursor: cursor, anchor: anchor });
        if (current.cursor === history.current.cursor && current.anchor === history.current.anchor)
            return history;
        return rebuild(history, history.undo, history.redo, current);
    }

    function record(history, nextState) {
        var next = state(nextState);
        if (next.text === history.current.text)
            return updateSelection(history, next.cursor, next.anchor);
        var undo = history.undo.slice();
        undo.push(state(history.current));
        return rebuild(history, trim(undo, history.limit), [], next);
    }

    function undo(history) {
        if (!history.undo.length)
            return { changed: false, history: history, state: state(history.current) };
        var undoEntries = history.undo.slice();
        var target = undoEntries.pop();
        var redoEntries = history.redo.slice();
        redoEntries.push(state(history.current));
        var next = rebuild(history, undoEntries, trim(redoEntries, history.limit), target);
        return { changed: true, history: next, state: state(next.current) };
    }

    function redo(history) {
        if (!history.redo.length)
            return { changed: false, history: history, state: state(history.current) };
        var redoEntries = history.redo.slice();
        var target = redoEntries.pop();
        var undoEntries = history.undo.slice();
        undoEntries.push(state(history.current));
        var next = rebuild(history, trim(undoEntries, history.limit), redoEntries, target);
        return { changed: true, history: next, state: state(next.current) };
    }

    function reset(value, limit) {
        return create(value, limit);
    }

    return Object.freeze({
        create: create,
        record: record,
        updateSelection: updateSelection,
        undo: undo,
        redo: redo,
        reset: reset,
        canUndo: function (history) { return history.undo.length > 0; },
        canRedo: function (history) { return history.redo.length > 0; }
    });
}());
