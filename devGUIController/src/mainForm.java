
import java.awt.List;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.ComboBoxModel;
import javax.swing.JRadioButton;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JOptionPane;
import javax.swing.JSlider;
import jssc.SerialPortException;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author derron
 */
public class mainForm extends javax.swing.JFrame {

    /**
     * Creates new form devGUIController
     */
    
     class mlogStream extends OutputStream
            {

       public mlogStream() { //To change body of generated methods, choose Tools | Templates.
        }
        
        @Override
        public void write(int b)
        {
            taLog.append(String.valueOf((char)b));
            taLog.setCaretPosition(taLog.getDocument().getLength());
        }
                
            }
     
    public mainForm() {
            this.initComponents();
            PrintStream ps = new PrintStream(new mlogStream());
            System.setErr(ps);
            System.setOut(ps);
    }   

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        modeGroup = new javax.swing.ButtonGroup();
        portsBox = new javax.swing.JComboBox<>();
        jButton1 = new javax.swing.JButton();
        sl_genFreq = new javax.swing.JSlider();
        sl_genAmp = new javax.swing.JSlider();
        sl_infFreq = new javax.swing.JSlider();
        sl_infAmp = new javax.swing.JSlider();
        rb_AM = new javax.swing.JRadioButton();
        rb_FM = new javax.swing.JRadioButton();
        jRadioButton3 = new javax.swing.JRadioButton();
        rb_PM = new javax.swing.JRadioButton();
        jScrollPane1 = new javax.swing.JScrollPane();
        taLog = new javax.swing.JTextArea();
        chb_signalSource = new javax.swing.JCheckBox();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        jLabel4 = new javax.swing.JLabel();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowOpened(java.awt.event.WindowEvent evt) {
                formWindowOpened(evt);
            }
        });

        portsBox.setName("portList"); // NOI18N

        jButton1.setText("Соединиться");
        jButton1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton1ActionPerformed(evt);
            }
        });

        sl_genFreq.setMaximum(200);
        sl_genFreq.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                sliderChange(evt);
            }
        });

        sl_genAmp.setMaximum(127);
        sl_genAmp.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                sliderChange(evt);
            }
        });

        sl_infFreq.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                sliderChange(evt);
            }
        });

        sl_infAmp.setMaximum(200);
        sl_infAmp.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                sliderChange(evt);
            }
        });

        modeGroup.add(rb_AM);
        rb_AM.setText("АМ");
        rb_AM.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                modeChanged(evt);
            }
        });

        modeGroup.add(rb_FM);
        rb_FM.setText("ЧМ");
        rb_FM.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                modeChanged(evt);
            }
        });

        modeGroup.add(jRadioButton3);
        jRadioButton3.setText("jRadioButton1");
        jRadioButton3.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                modeChanged(evt);
            }
        });

        modeGroup.add(rb_PM);
        rb_PM.setText("ФМ");
        rb_PM.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                modeChanged(evt);
            }
        });

        taLog.setEditable(false);
        taLog.setColumns(20);
        taLog.setFont(new java.awt.Font("Arial", 0, 12)); // NOI18N
        taLog.setRows(5);
        jScrollPane1.setViewportView(taLog);

        chb_signalSource.setText("Внутренний/ внешний инф. сигнал");

        jLabel1.setText("Частота несущей");

        jLabel2.setText("Амплитуда несущей");

        jLabel3.setText("Частота инф. сигнала");

        jLabel4.setText("Амплитуда инф. сигнала");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(rb_AM)
                            .addComponent(rb_PM)
                            .addComponent(chb_signalSource)
                            .addComponent(portsBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(jButton1))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jLabel3, javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jLabel1, javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jLabel2, javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jLabel4, javax.swing.GroupLayout.Alignment.TRAILING)))
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(rb_FM)
                            .addComponent(jRadioButton3))
                        .addGap(0, 0, Short.MAX_VALUE)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(sl_genFreq, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(sl_infFreq, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(sl_genAmp, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(sl_infAmp, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(20, 20, 20))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(portsBox, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(jButton1)
                            .addComponent(jLabel1))
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jLabel2))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(sl_genFreq, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(sl_genAmp, javax.swing.GroupLayout.PREFERRED_SIZE, 28, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(sl_infFreq, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                    .addComponent(jLabel4, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addComponent(chb_signalSource)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(rb_AM)
                        .addGap(17, 17, 17)
                        .addComponent(rb_PM)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(rb_FM, javax.swing.GroupLayout.PREFERRED_SIZE, 32, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jRadioButton3))
                    .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                        .addComponent(sl_infAmp, javax.swing.GroupLayout.PREFERRED_SIZE, 24, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(jLabel3)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 35, Short.MAX_VALUE)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 137, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    @SuppressWarnings("empty-statement")
    private void formWindowOpened(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_formWindowOpened
        String[] names = jssc.SerialPortList.getPortNames();
        portsBox.setModel(new DefaultComboBoxModel(names));
        
    }//GEN-LAST:event_formWindowOpened

    private void jButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton1ActionPerformed
        try {
            dc = new devConnector((String) portsBox.getSelectedItem());
            System.out.println("Connection established");
        } catch (SerialPortException ex) {
            Logger.getLogger(mainForm.class.getName()).log(Level.SEVERE, null, ex);
            JOptionPane.showMessageDialog(this, "Не удалось открыть порт");
        }
    }//GEN-LAST:event_jButton1ActionPerformed

    private void modeChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_modeChanged
       javax.swing.JRadioButton j =  (javax.swing.JRadioButton) evt.getSource();
       try{  
       int sigSource;
       if(chb_signalSource.isSelected()) sigSource = dc.INTERNAL;
       else sigSource =dc.EXTERNAL;
       if(j == rb_AM)
       {
           dc.sendCmd(dc.SETMODE, dc.AM_MODE | sigSource);
       }
       else if (j == rb_PM)
       {
           dc.sendCmd(dc.SETMODE, dc.PM_MODE | sigSource);
       }
       else if (j == rb_FM)
       {
           dc.sendCmd(dc.SETMODE, dc.FM_MODE | sigSource);
       }
       }
       catch(Exception ex)
       {
           Logger.getLogger(mainForm.class.getName()).log(Level.SEVERE, null, ex);
       }
    }//GEN-LAST:event_modeChanged

    private void sliderChange(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_sliderChange
        JSlider slider = (JSlider) evt.getSource();
        int value = slider.getValue();
        try
        {
            if(slider == sl_genFreq)
            {
                dc.sendCmd(dc.SET_GEN_FREQ, value);
            }
            else if (slider == sl_genAmp)
            {
                dc.sendCmd(dc.SET_GEN_AMP, value);
            }
            else if (slider == sl_infFreq)
                dc.sendCmd(dc.SET_INF_FREQ, value);
            else if (slider == sl_infAmp)
                dc.sendCmd(dc.SET_INF_AMP, value);
        }
        catch(Exception ex)
        {
              Logger.getLogger(mainForm.class.getName()).log(Level.SEVERE, null, ex);
        }
    }//GEN-LAST:event_sliderChange

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(mainForm.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(mainForm.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(mainForm.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(mainForm.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>
        //</editor-fold>

        /* Create and display the form */
        
        if(args.length>0)
        {
           try{
          //  devConnector.TIMEOUT = Integer.parseInt(args[0]);
           }
           catch(Exception e){}
        }
        
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new mainForm().setVisible(true);
            }
        });
    }

    private devConnector dc;
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JCheckBox chb_signalSource;
    private javax.swing.JButton jButton1;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JRadioButton jRadioButton3;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.ButtonGroup modeGroup;
    private javax.swing.JComboBox<String> portsBox;
    private javax.swing.JRadioButton rb_AM;
    private javax.swing.JRadioButton rb_FM;
    private javax.swing.JRadioButton rb_PM;
    private javax.swing.JSlider sl_genAmp;
    private javax.swing.JSlider sl_genFreq;
    private javax.swing.JSlider sl_infAmp;
    private javax.swing.JSlider sl_infFreq;
    private javax.swing.JTextArea taLog;
    // End of variables declaration//GEN-END:variables
}