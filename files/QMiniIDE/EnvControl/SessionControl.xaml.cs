using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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

namespace EnvControls
{
    /// <summary>
    /// SessionControl.xaml 的交互逻辑
    /// </summary>
    public partial class SessionControl : UserControl
    {
        public SessionControl()
        {
            InitializeComponent();
        }

        private void goNavigateButton_Click(object sender, RoutedEventArgs e)
        {
            //Uri uri = new Uri(this.addressTextBox.Text, UriKind.RelativeOrAbsolute);

            Uri uriResult;
            if (this.addressTextBox.Text.Length > 0) {
                bool result = Uri.TryCreate(this.addressTextBox.Text, UriKind.Absolute, out uriResult)
                              && (uriResult.Scheme == Uri.UriSchemeHttp
                                  || uriResult.Scheme == Uri.UriSchemeHttps);
                if(result)
                    this.myWebBrower.Navigate(uriResult);
            }

            
        }
    }
}
