using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace ConsoleControls
{
    /// <summary>
    /// ConsoleContainer.xaml 的交互逻辑
    /// </summary>
    public partial class ConsoleContainer : UserControl
    {
        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32")]
        private static extern IntPtr SetParent(IntPtr hWnd, IntPtr hWndParent);

        [DllImport("user32")]
        private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, int uFlags);

        private const int SWP_NOZORDER = 0x0004;
        private const int SWP_NOACTIVATE = 0x0010;
        private const int GWL_STYLE = -16;
        private const int WS_CAPTION = 0x00C00000;
        private const int WS_THICKFRAME = 0x00040000;
        const string patran = "patran";

        private Process _process;
        private IntPtr hWndDocked;
        private System.Windows.Forms.Panel _panel;

        public ConsoleContainer()
        {
            InitializeComponent();
            _panel = new System.Windows.Forms.Panel();
            windowsFormsHost.Child = _panel;
        }

        private void ResizeEmbeddedApp()
        {
            if (_process == null)
                return;
            SetWindowPos(_process.MainWindowHandle, IntPtr.Zero, 0, 0, (int)_panel.ClientSize.Width, (int)_panel.ClientSize.Height, SWP_NOZORDER | SWP_NOACTIVATE);
            int style = GetWindowLong(_process.MainWindowHandle, GWL_STYLE);
            style = style & ~((int)WS_CAPTION); // Removes Caption bar and the sizing border
            SetWindowLong(_process.MainWindowHandle, GWL_STYLE, style);
        }

        void window_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            ResizeEmbeddedApp();
        }

        private void startbtn_Click(object sender, RoutedEventArgs e)
        {
            ProcessStartInfo psi = new ProcessStartInfo(@"C:\q\w32\q.exe");
            psi.WindowStyle = ProcessWindowStyle.Normal;
            _process = Process.Start(psi);

            while (hWndDocked == IntPtr.Zero)
            {
                Thread.Sleep(100);
                //_process.WaitForInputIdle(1000); //wait for the window to be ready for input;
                _process.Refresh();              //update process info
                if (_process.HasExited)
                {
                    return; //abort if the process finished before we got a handle.
                }
                hWndDocked = _process.MainWindowHandle;  //cache the window handle
            }

            //SetParent(_process.MainWindowHandle, helper.Handle);
            SetParent(_process.MainWindowHandle, _panel.Handle);

            // resize embedded application & refresh
            SizeChanged += window_SizeChanged;
            ResizeEmbeddedApp();
        }

        private void stopbtn_Click(object sender, RoutedEventArgs e)
        {
            if (!_process.HasExited)
            {
                // Close process by sending a close message to its main window.
                _process.CloseMainWindow();
                // Free resources associated with process.
                _process.Close();
                // Reset dock flag
                hWndDocked = IntPtr.Zero;
            }
        }
    }
}
