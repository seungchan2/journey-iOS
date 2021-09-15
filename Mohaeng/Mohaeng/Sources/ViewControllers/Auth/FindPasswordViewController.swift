//
//  FindPasswordViewController.swift
//  Journey
//
//  Created by 초이 on 2021/07/11.
//

import UIKit

class FindPasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    let user = User.shared
    
    // MARK: - @IBOutlet Properties
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        initViewRounding()
        setDelegation()
    }
    
    // MARK: - Functions
    
    private func initNavigationBar() {
        self.navigationController?.initNavigationBarWithBackButton(navigationItem: self.navigationItem)
        // navigationItem.title = "비밀번호 찾기"
    }
    
    private func initViewRounding() {
        self.nextButton.makeRounded(radius: nextButton.frame.height / 2)
    }
    
    private func setDelegation() {
        emailTextField.delegate = self
    }
    
    private func checkEmailFormat(email: String) {
        if validateEmail(email: email) {
            nextButton.isEnabled = true
            nextButton.alpha = 1.0
            
            errorLabel.isHidden = true
        } else {
            nextButton.isEnabled = false
            nextButton.alpha = 0.3
            
            errorLabel.isHidden = false
            // TODO: - 이메일 형식에 맞지 않음 오류 메세지 fix되면 띄우기
        }
    }
    
    func validateEmail(email: String) -> Bool {
        // Email 정규식
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func pushToCodeViewController(code: Int) {
        let codeStoryboard = UIStoryboard(name: Const.Storyboard.Name.code, bundle: nil)
        guard let codeViewController = codeStoryboard.instantiateViewController(identifier: Const.ViewController.Identifier.code) as? CodeViewController else { return }
        
        codeViewController.rightCode = code
        
        self.navigationController?.pushViewController(codeViewController, animated: true)
    }
    
    // MARK: - @IBAction Functions
    
    @IBAction func touchNextButton(_ sender: Any) {
        getCode()
    }
    
}

extension FindPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailLabel.textColor = UIColor.black
        underlineView.backgroundColor = UIColor.black
    }
    
    // 실시간
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        checkEmailFormat(email: text)
        return true
    }
    
    // 키보드 내렸을 때 (.co 등 때문에 추가)
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        checkEmailFormat(email: text)
        emailLabel.textColor = UIColor.Black3Text
        underlineView.backgroundColor = UIColor.Grey1Line
    }
}

extension FindPasswordViewController {
    
    func getCode() {
        
        if let email = self.emailTextField.text {
            
            PasswordAPI.shared.getEmailCode(completion: { (result) in
                switch result {
                case .success(let code):
                    
                    if let data = code as? CodeData {
                        self.errorLabel.isHidden = true
                        self.pushToCodeViewController(code: data.number)
                        self.user.email = email
                    }
                case .requestErr(let message):
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = "\(message)"
                    print("requestErr", message)
                case .pathErr:
                    print(".pathErr")
                case .serverErr:
                    print("serverErr")
                case .networkFail:
                    print("networkFail")
                }
            }, email: email)
            
        }
    }
    
}