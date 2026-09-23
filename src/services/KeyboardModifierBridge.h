#pragma once

#include <QObject>
#include <QTimer>

class KeyboardModifierBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool shiftPressed READ shiftPressed NOTIFY shiftPressedChanged)

public:
    explicit KeyboardModifierBridge(QObject *parent = nullptr);
    ~KeyboardModifierBridge() override;

    bool shiftPressed() const;

signals:
    void shiftPressedChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    void setShiftPressed(bool pressed);

    bool m_shiftPressed = false;
    QTimer m_shiftReleaseTimer;
};
